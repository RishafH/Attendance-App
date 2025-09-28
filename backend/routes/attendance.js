const express = require('express');
const { body, validationResult, param, query } = require('express-validator');
const Attendance = require('../models/Attendance');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Validation middleware
const validateAttendance = [
  body('date')
    .notEmpty()
    .withMessage('Date is required')
    .isISO8601()
    .withMessage('Date must be a valid ISO 8601 date'),
  body('isPresent')
    .isBoolean()
    .withMessage('Present status must be a boolean'),
  body('billsCount')
    .isInt({ min: 0 })
    .withMessage('Bills count must be a non-negative integer'),
  body('startTime')
    .optional()
    .isISO8601()
    .withMessage('Start time must be a valid ISO 8601 datetime'),
  body('endTime')
    .optional()
    .isISO8601()
    .withMessage('End time must be a valid ISO 8601 datetime'),
  body('remarks')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Remarks must be less than 500 characters')
];

// @route   POST /api/attendance
// @desc    Create attendance record
// @access  Private
router.post('/', auth, validateAttendance, async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { date, isPresent, startTime, endTime, billsCount, remarks } = req.body;
    const employeeId = req.employee._id;

    // Parse date to ensure we're working with date only (no time)
    const attendanceDate = new Date(date);
    attendanceDate.setHours(0, 0, 0, 0);

    // Check if attendance already exists for this date
    const existingAttendance = await Attendance.findOne({
      employeeId,
      date: attendanceDate
    });

    if (existingAttendance) {
      // Update existing attendance
      existingAttendance.isPresent = isPresent;
      existingAttendance.startTime = startTime ? new Date(startTime) : null;
      existingAttendance.endTime = endTime ? new Date(endTime) : null;
      existingAttendance.billsCount = billsCount;
      existingAttendance.remarks = remarks;

      await existingAttendance.save();
      
      return res.json({
        success: true,
        message: 'Attendance updated successfully',
        data: existingAttendance
      });
    }

    // Create new attendance record
    const attendance = new Attendance({
      employeeId,
      date: attendanceDate,
      isPresent,
      startTime: startTime ? new Date(startTime) : null,
      endTime: endTime ? new Date(endTime) : null,
      billsCount,
      remarks
    });

    await attendance.save();

    res.status(201).json({
      success: true,
      message: 'Attendance created successfully',
      data: attendance
    });

  } catch (error) {
    console.error('Create attendance error:', error);
    
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Attendance already exists for this date'
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Server error while creating attendance'
    });
  }
});

// @route   GET /api/attendance/:employeeId
// @desc    Get attendance records for an employee
// @access  Private
router.get('/:employeeId', 
  auth,
  param('employeeId').isMongoId().withMessage('Invalid employee ID'),
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: errors.array()
        });
      }

      const { employeeId } = req.params;
      
      // Employees can only access their own records, admins can access any
      if (req.employee.role !== 'admin' && req.employee._id.toString() !== employeeId) {
        return res.status(403).json({
          success: false,
          message: 'Access denied'
        });
      }

      const attendance = await Attendance.find({ employeeId })
        .sort({ date: -1 })
        .populate('employeeId', 'username name');

      res.json({
        success: true,
        data: attendance
      });

    } catch (error) {
      console.error('Get attendance error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error while fetching attendance'
      });
    }
  }
);

// @route   GET /api/attendance/:employeeId/monthly
// @desc    Get monthly attendance records
// @access  Private
router.get('/:employeeId/monthly',
  auth,
  param('employeeId').isMongoId().withMessage('Invalid employee ID'),
  query('month').isInt({ min: 1, max: 12 }).withMessage('Month must be between 1 and 12'),
  query('year').isInt({ min: 2020 }).withMessage('Year must be 2020 or later'),
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: errors.array()
        });
      }

      const { employeeId } = req.params;
      const { month, year } = req.query;
      
      // Access control
      if (req.employee.role !== 'admin' && req.employee._id.toString() !== employeeId) {
        return res.status(403).json({
          success: false,
          message: 'Access denied'
        });
      }

      const startDate = new Date(parseInt(year), parseInt(month) - 1, 1);
      const endDate = new Date(parseInt(year), parseInt(month), 0, 23, 59, 59);

      const attendance = await Attendance.find({
        employeeId,
        date: {
          $gte: startDate,
          $lte: endDate
        }
      }).sort({ date: 1 });

      const summary = await Attendance.getMonthlySummary(employeeId, parseInt(month), parseInt(year));

      res.json({
        success: true,
        data: attendance,
        summary: {
          month: parseInt(month),
          year: parseInt(year),
          ...summary
        }
      });

    } catch (error) {
      console.error('Get monthly attendance error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error while fetching monthly attendance'
      });
    }
  }
);

// @route   PUT /api/attendance/:id
// @desc    Update attendance record
// @access  Private
router.put('/:id',
  auth,
  param('id').isMongoId().withMessage('Invalid attendance ID'),
  validateAttendance,
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: errors.array()
        });
      }

      const { id } = req.params;
      const { date, isPresent, startTime, endTime, billsCount, remarks } = req.body;

      const attendance = await Attendance.findById(id);
      if (!attendance) {
        return res.status(404).json({
          success: false,
          message: 'Attendance record not found'
        });
      }

      // Access control
      if (req.employee.role !== 'admin' && 
          req.employee._id.toString() !== attendance.employeeId.toString()) {
        return res.status(403).json({
          success: false,
          message: 'Access denied'
        });
      }

      // Update attendance
      const attendanceDate = new Date(date);
      attendanceDate.setHours(0, 0, 0, 0);

      attendance.date = attendanceDate;
      attendance.isPresent = isPresent;
      attendance.startTime = startTime ? new Date(startTime) : null;
      attendance.endTime = endTime ? new Date(endTime) : null;
      attendance.billsCount = billsCount;
      attendance.remarks = remarks;

      await attendance.save();

      res.json({
        success: true,
        message: 'Attendance updated successfully',
        data: attendance
      });

    } catch (error) {
      console.error('Update attendance error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error while updating attendance'
      });
    }
  }
);

// @route   DELETE /api/attendance/:id
// @desc    Delete attendance record
// @access  Private
router.delete('/:id',
  auth,
  param('id').isMongoId().withMessage('Invalid attendance ID'),
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: errors.array()
        });
      }

      const { id } = req.params;

      const attendance = await Attendance.findById(id);
      if (!attendance) {
        return res.status(404).json({
          success: false,
          message: 'Attendance record not found'
        });
      }

      // Access control
      if (req.employee.role !== 'admin' && 
          req.employee._id.toString() !== attendance.employeeId.toString()) {
        return res.status(403).json({
          success: false,
          message: 'Access denied'
        });
      }

      await Attendance.findByIdAndDelete(id);

      res.json({
        success: true,
        message: 'Attendance deleted successfully'
      });

    } catch (error) {
      console.error('Delete attendance error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error while deleting attendance'
      });
    }
  }
);

module.exports = router;