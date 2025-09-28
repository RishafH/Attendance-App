const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({
  employeeId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Employee',
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  isPresent: {
    type: Boolean,
    required: true,
    default: false
  },
  startTime: {
    type: Date,
    validate: {
      validator: function(startTime) {
        return !this.isPresent || startTime != null;
      },
      message: 'Start time is required when present'
    }
  },
  endTime: {
    type: Date,
    validate: {
      validator: function(endTime) {
        return !this.isPresent || endTime != null;
      },
      message: 'End time is required when present'
    }
  },
  billsCount: {
    type: Number,
    required: true,
    min: 0,
    default: 0
  },
  remarks: {
    type: String,
    trim: true,
    maxlength: 500
  },
  basePayment: {
    type: Number,
    required: true,
    min: 0,
    default: 0
  },
  incentives: {
    type: Number,
    required: true,
    min: 0,
    default: 0
  },
  totalSalary: {
    type: Number,
    required: true,
    min: 0,
    default: 0
  }
}, {
  timestamps: true
});

// Create compound index to prevent duplicate attendance for same day
attendanceSchema.index({ employeeId: 1, date: 1 }, { 
  unique: true,
  partialFilterExpression: {
    date: { $type: 'date' }
  }
});

// Pre-save middleware to calculate payments
attendanceSchema.pre('save', function(next) {
  if (this.isPresent) {
    // Base payment is 1000 if present
    this.basePayment = 1000;
    
    // If bills < 10, give half payment
    if (this.billsCount < 10) {
      this.basePayment = 500;
    }
    
    // Calculate incentives
    if (this.billsCount >= 25) {
      this.incentives = 1000;
    } else if (this.billsCount >= 20) {
      this.incentives = 500;
    } else {
      this.incentives = 0;
    }
  } else {
    // If absent, no payment
    this.basePayment = 0;
    this.incentives = 0;
    this.billsCount = 0;
  }
  
  // Calculate total salary
  this.totalSalary = this.basePayment + this.incentives;
  
  next();
});

// Static method to get monthly summary
attendanceSchema.statics.getMonthlySummary = async function(employeeId, month, year) {
  const startDate = new Date(year, month - 1, 1);
  const endDate = new Date(year, month, 0, 23, 59, 59);
  
  const pipeline = [
    {
      $match: {
        employeeId: new mongoose.Types.ObjectId(employeeId),
        date: {
          $gte: startDate,
          $lte: endDate
        }
      }
    },
    {
      $group: {
        _id: null,
        totalWorkingDays: { $sum: 1 },
        presentDays: { 
          $sum: { 
            $cond: ['$isPresent', 1, 0] 
          } 
        },
        absentDays: { 
          $sum: { 
            $cond: ['$isPresent', 0, 1] 
          } 
        },
        totalBills: { $sum: '$billsCount' },
        totalIncentives: { $sum: '$incentives' },
        totalSalary: { $sum: '$totalSalary' }
      }
    }
  ];
  
  const result = await this.aggregate(pipeline);
  
  if (result.length === 0) {
    return {
      totalWorkingDays: 0,
      presentDays: 0,
      absentDays: 0,
      totalBills: 0,
      totalIncentives: 0,
      totalSalary: 0,
      averageBillsPerDay: 0
    };
  }
  
  const summary = result[0];
  summary.averageBillsPerDay = summary.presentDays > 0 ? 
    summary.totalBills / summary.presentDays : 0;
    
  delete summary._id;
  return summary;
};

module.exports = mongoose.model('Attendance', attendanceSchema);