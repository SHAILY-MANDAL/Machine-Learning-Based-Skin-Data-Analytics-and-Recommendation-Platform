from flask import Flask, request, jsonify
import cv2
import numpy as np
import os
import pandas as pd
from werkzeug.utils import secure_filename
from inference_sdk import InferenceHTTPClient

# Initialize Flask app
app = Flask(__name__)

# Set upload folder
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Load Inference Client
CLIENT = InferenceHTTPClient(
    api_url="https://classify.roboflow.com",
    api_key="hiNFrsKV6b1wmbyc1i04"
)

# Define skin conditions
ANALYSIS_FACTORS = [
    "Acne", "Blackheads", "Dark Spots", "Dry Skin", "Eye Bags",
    "Normal Skin", "Oily Skin", "Pores", "Skin Redness", "Wrinkles"
]

def split_and_infer(image_path):
    """Splits the image into parts, runs inference, and gets max confidences."""
    image = cv2.imread(image_path)
    height, width, _ = image.shape
    step_x = width // 5
    step_y = height // 5
    max_confidences = {condition: 0 for condition in ANALYSIS_FACTORS}

    for i in range(5):
        for j in range(5):
            x1, y1 = i * step_x, j * step_y
            x2, y2 = (i + 1) * step_x, (j + 1) * step_y
            cropped_image = image[y1:y2, x1:x2]
            temp_path = "temp_crop.jpg"
            cv2.imwrite(temp_path, cropped_image)
            
            try:
                result = CLIENT.infer(temp_path, model_id="skin-problem-multilabel/1")
                predictions = result.get("predictions", {})
                
                for condition, data in predictions.items():
                    confidence = data["confidence"] * 100
                    max_confidences[condition] = round(max(max_confidences.get(condition, 0), confidence), 2)
            except Exception as e:
                print(f"Error during inference for segment ({i}, {j}): {e}")
    
    return max_confidences

def get_range(confidence):
    """Categorizes confidence into ranges."""
    if confidence <= 25:
        return "Low"
    elif confidence <= 50:
        return "Moderate"
    elif confidence <= 75:
        return "High"
    else:
        return "Very High"

def find_best_match(df, test_case):
    """Finds the best matching product URL based on skin analysis."""
    df["match_score"] = df.apply(lambda row: sum(row[col] == test_case[col] for col in test_case.keys()), axis=1)
    best_match = df.loc[df["match_score"].idxmax()]
    return best_match["URL"]

@app.route('/analyze', methods=['POST'])
def analyze():
    """Handles image upload, analysis, and returns recommendations."""
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400
    
    file = request.files['image']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    
    filename = secure_filename(file.filename)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)
    
    print(f"Image saved at: {filepath}")  # Debug print

    # Run inference
    analysis_results = split_and_infer(filepath)
    
    print(f"Inference Results: {analysis_results}")  # Debug print

    # Extract confidences separately
    confidences = {condition: analysis_results.get(condition, 0) for condition in ANALYSIS_FACTORS}

    print(f"Confidences Extracted: {confidences}")  # Debug print

    # Process results
    selected_conditions = ["Acne", "Dark Spots", "Oily Skin", "Dry Skin", "Skin Redness"]
    test_case = {condition: get_range(confidences.get(condition, 0)) for condition in selected_conditions}

    print(f"Test Case for Matching: {test_case}")  # Debug print

    # Load product data
    file_path = "products.csv"
    if not os.path.exists(file_path):
        return jsonify({"error": "Product database not found"}), 500
    df = pd.read_csv(file_path)
    
    best_url = find_best_match(df, test_case)

    print(f"Best Matched URL: {best_url}")  # Debug print

    recommendations = {
        "best_match": best_url,
        "specific_recommendations": {}
    }
    
    if confidences.get("Blackheads", 0) > 50:
        recommendations["specific_recommendations"]["Blackheads"] = "https://www.amazon.in/dp/B0DCC1YHCL"
    if confidences.get("Wrinkles", 0) > 50:
        recommendations["specific_recommendations"]["Wrinkles"] = "https://amzn.in/d/csCZKbS"
    if confidences.get("Pores", 0) > 50:
        recommendations["specific_recommendations"]["Pores"] = "https://www.amazon.in/Lacto-Calamine-Niacinamide"
    if confidences.get("Eye Bags", 0) > 50:
        recommendations["specific_recommendations"]["Eye Bags"] = "https://amzn.in/d/aqe5ZTQ"

    print(f"Final Recommendations: {recommendations}")  # Debug print
    
    # Sending each confidence separately
    response_data = {
        "best match": recommendations["best_match"],
        "recommendations": recommendations["specific_recommendations"]
    }

    # Adding individual confidences to the response
    for condition in ANALYSIS_FACTORS:
        response_data[condition] = confidences[condition]

    print(f"Final Response Data: {response_data}")  # Debug print

    return jsonify(response_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)