const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const cookieParser = require('cookie-parser');

dotenv.config();
const app = express();

const PORT = process.env.PORT || 5002;
app.use(express.json());
app.use(cookieParser());
app.use(cors())

const authRouter = require('./src/routes/authroutes.js')
const accountsRouter = require('./src/routes/accountRoutes.js')

app.use('/api/auth',authRouter)
app.use('/api/accounts',accountsRouter)

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
})

module.exports = app;