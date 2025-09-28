# Pegas Salary & Attendance App Backend

This is the backend API for the Pegas Salary & Attendance mobile application built with Node.js, Express.js, and MongoDB.

## Features

- Employee authentication with JWT
- Attendance record management
- Salary calculation with business logic
- Monthly summaries and reports
- Role-based access control
- Input validation and security middleware

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (local or cloud instance)
- npm or yarn package manager

## Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
Copy the `.env` file and update the values as needed:
- `MONGODB_URI`: Your MongoDB connection string
- `JWT_SECRET`: Secret key for JWT tokens (change in production)
- `PORT`: Server port (default: 3000)

4. Create demo users:
```bash
node createDemoUsers.js
```

## Running the Server

### Development mode:
```bash
npm run dev
```

### Production mode:
```bash
npm start
```

The server will start on `http://localhost:3000` (or your specified PORT).

## API Endpoints

### Authentication
- `POST /api/auth/login` - Employee login
- `POST /api/auth/register` - Register new employee
- `GET /api/auth/verify` - Verify JWT token

### Attendance
- `POST /api/attendance` - Create/update attendance record
- `GET /api/attendance/:employeeId` - Get employee attendance records
- `GET /api/attendance/:employeeId/monthly` - Get monthly attendance with summary
- `PUT /api/attendance/:id` - Update specific attendance record
- `DELETE /api/attendance/:id` - Delete attendance record

### Health Check
- `GET /api/health` - Server health status

## Business Logic

### Salary Calculation
- **Base Payment**: Rs. 1000 for present days
- **Half Payment**: Rs. 500 if bills count < 10
- **Incentives**: 
  - Rs. 500 for 20-24 bills
  - Rs. 1000 for 25+ bills
- **Total Salary**: Base Payment + Incentives

### Access Control
- Employees can only access their own records
- Admins can access all employee records
- JWT authentication required for all protected routes

## Demo Accounts

The system creates demo accounts automatically:

**Demo Employee:**
- Username: `demo`
- Password: `demo`

**Admin User:**
- Username: `admin`
- Password: `admin123`

## Database Schema

### Employee
- username (unique)
- password (hashed)
- name
- email (optional)
- phone (optional)
- role (employee/admin)
- isActive (boolean)

### Attendance
- employeeId (reference to Employee)
- date
- isPresent (boolean)
- startTime, endTime
- billsCount
- remarks
- basePayment, incentives, totalSalary (calculated)

## Security Features

- Password hashing with bcryptjs
- JWT token authentication
- Rate limiting
- Input validation with express-validator
- Helmet.js for security headers
- CORS configuration

## Error Handling

The API returns consistent error responses:
```json
{
  "success": false,
  "message": "Error description",
  "errors": [] // Validation errors if applicable
}
```

## Development

The server uses nodemon for development with hot reloading. Logs are configured with morgan for request tracking.

## Production Deployment

1. Set `NODE_ENV=production`
2. Use a production MongoDB instance
3. Update JWT_SECRET with a secure random string
4. Configure CORS for your frontend domain
5. Set up proper logging and monitoring

## API Documentation

For detailed API documentation and examples, refer to the endpoint comments in the route files or set up tools like Swagger/OpenAPI documentation.