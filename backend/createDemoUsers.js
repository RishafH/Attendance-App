const mongoose = require('mongoose');
const Employee = require('./models/Employee');
require('dotenv').config();

const createDemoUsers = async () => {
  try {
    // Connect to database
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/pegas_attendance';
    await mongoose.connect(mongoURI);
    console.log('Connected to MongoDB for demo user creation');

    // Create demo employee if doesn't exist
    const demoUsername = process.env.DEMO_USERNAME || 'demo';
    const existingDemo = await Employee.findOne({ username: demoUsername });
    
    if (!existingDemo) {
      const demoEmployee = new Employee({
        username: demoUsername,
        password: process.env.DEMO_PASSWORD || 'demo',
        name: process.env.DEMO_NAME || 'Demo Employee',
        email: 'demo@pegas.com',
        phone: '+94771234567',
        role: 'employee'
      });
      
      await demoEmployee.save();
      console.log(`Demo employee created: ${demoUsername}`);
    } else {
      console.log(`Demo employee already exists: ${demoUsername}`);
    }

    // Create admin user if doesn't exist
    const adminUsername = process.env.DEFAULT_ADMIN_USERNAME || 'admin';
    const existingAdmin = await Employee.findOne({ username: adminUsername });
    
    if (!existingAdmin) {
      const adminEmployee = new Employee({
        username: adminUsername,
        password: process.env.DEFAULT_ADMIN_PASSWORD || 'admin123',
        name: process.env.DEFAULT_ADMIN_NAME || 'System Administrator',
        email: 'admin@pegas.com',
        role: 'admin'
      });
      
      await adminEmployee.save();
      console.log(`Admin user created: ${adminUsername}`);
    } else {
      console.log(`Admin user already exists: ${adminUsername}`);
    }

    console.log('Demo user creation completed');
    process.exit(0);

  } catch (error) {
    console.error('Error creating demo users:', error);
    process.exit(1);
  }
};

// Run if this script is executed directly
if (require.main === module) {
  createDemoUsers();
}

module.exports = createDemoUsers;