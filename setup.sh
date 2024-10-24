#!/bin/bash

# Project Name
PROJECT_NAME="neuralink-health-monitor"

# Step 1: Create the Project Directory
echo "Creating project directory..."
mkdir $PROJECT_NAME
cd $PROJECT_NAME

# Step 2: Set Up Backend (Node.js/Express)
echo "Setting up backend..."
mkdir backend
cd backend

# Initialize Node.js project
npm init -y

# Install dependencies
npm install express body-parser cors mongoose

# Create server.js file
cat <<EOL >server.js
const express = require("express");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const app = express();

app.use(bodyParser.json());

// MongoDB connection
mongoose.connect("mongodb://localhost:27017/healthdata", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Schema for Health Data
const healthSchema = new mongoose.Schema({
  userId: String,
  vitalSigns: Object,
  brainActivity: Array,
  timestamp: Date,
});

const HealthData = mongoose.model("HealthData", healthSchema);

// API to Post Data
app.post("/api/v1/healthdata", async (req, res) => {
  const healthData = new HealthData(req.body);
  await healthData.save();
  res.json({ success: true });
});

// Sample AI endpoint for disease prediction
app.post("/api/v1/predict", (req, res) => {
  const { brainActivity } = req.body;
  const prediction = aiModel(brainActivity); // Call your AI model here
  res.json({ prediction });
});

app.listen(5000, () => {
  console.log("Backend server is running on port 5000");
});
EOL

# Return to project root
cd ..

# Step 3: Set Up AI Model (Python/Flask)
echo "Setting up AI model..."
mkdir ai_model
cd ai_model

# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install flask tensorflow numpy pandas

# Create ai_model.py
cat <<EOL >ai_model.py
import tensorflow as tf
import numpy as np
from flask import Flask, request, jsonify

app = Flask(__name__)

# Define a simple AI model
model = tf.keras.Sequential([
    tf.keras.layers.Dense(64, activation='relu', input_shape=(10,)),
    tf.keras.layers.Dense(1, activation='sigmoid')
])

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

@app.route("/api/v1/predict", methods=["POST"])
def predict():
    data = np.array(request.json["brainActivity"]).reshape(-1, 10)
    prediction = model.predict(data)
    return jsonify({"prediction": prediction.tolist()})

if __name__ == "__main__":
    app.run(port=5001)
EOL

# Return to project root
cd ..

# Step 4: Set Up Frontend (React/Next.js)
echo "Setting up frontend..."
mkdir frontend
cd frontend

# Create Next.js app
npx create-next-app@latest .

# Install Tailwind CSS and Axios
npm install tailwindcss axios

# Configure Tailwind CSS
npx tailwindcss init

# Update Tailwind config
cat <<EOL >tailwind.config.js
module.exports = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOL

# Add Tailwind directives to globals.css
cat <<EOL >styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

# Create basic frontend page
cat <<EOL >pages/index.js
import Head from 'next/head';
import { useState } from 'react';
import axios from 'axios';

export default function Home() {
  const [brainActivity, setBrainActivity] = useState([]);
  const [prediction, setPrediction] = useState(null);

  const handlePredict = async () => {
    try {
      const response = await axios.post('http://localhost:5001/api/v1/predict', {
        brainActivity
      });
      setPrediction(response.data.prediction);
    } catch (error) {
      console.error("Error predicting:", error);
    }
  };

  return (
    <div>
      <Head>
        <title>Neuralink Health Monitor</title>
      </Head>
      <main className="flex flex-col items-center">
        <h1 className="text-2xl mt-5">Neuralink Health Monitor</h1>
        <input
          type="text"
          value={brainActivity}
          onChange={(e) => setBrainActivity(e.target.value.split(',').map(Number))}
          placeholder="Enter brain activity (comma-separated)"
        />
        <button onClick={handlePredict} className="mt-3 bg-blue-500 text-white p-2 rounded">
          Predict
        </button>
        {prediction && (
          <div className="mt-3">Prediction: {prediction}</div>
        )}
      </main>
    </div>
  );
}
EOL

# Return to project root
cd ..

# Step 5: Instructions to Run the Servers
echo "To start the project, follow these steps:"

echo "
1. Start MongoDB if it's not running: \`mongod\`
2. Start the backend server:
    cd $PROJECT_NAME/backend
    node server.js

3. Start the AI model server:
    cd $PROJECT_NAME/ai_model
    source venv/bin/activate
    python ai_model.py

4. Start the frontend server:
    cd $PROJECT_NAME/frontend
    npm run dev

Then, open your browser and navigate to http://localhost:3000 to use the app.
"
