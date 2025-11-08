# AI Models

AI/ML models for the Tiraz platform (MVP).

## Components

### 1. Measurement Model
Computer vision model for extracting body measurements from photos.

**Technology Stack:**
- Python 3.8+
- OpenCV for image processing
- TensorFlow/PyTorch for deep learning
- MediaPipe for pose detection

**Input:** 4 photos (front, back, left, right) + height/weight
**Output:** Body measurements (chest, waist, shoulders, etc.)

### 2. Virtual Try-On Model (Future)
3D body model generation and garment draping (Phase 2).

## Setup

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

## Requirements

See `requirements.txt` for Python dependencies:
- opencv-python
- tensorflow or pytorch
- mediapipe
- numpy
- pillow
- flask (for API service)

## Running the Measurement Service

```bash
# Activate virtual environment
source venv/bin/activate

# Run the measurement API
python measurement_model/api.py
```

The service will run on `http://localhost:8000`

## API Endpoints

### Process Measurements
```
POST /api/measurements/process
Content-Type: multipart/form-data

Body:
- photo_front: file
- photo_back: file
- photo_left: file
- photo_right: file
- height: number (cm)
- weight: number (kg)

Response:
{
  "measurements": {
    "chest": 98,
    "waist": 82,
    "shoulders": 44,
    "arm_length": 62,
    "neck": 38,
    "hip": 96
  },
  "unit": "cm",
  "confidence": 0.95
}
```

## Model Training (Future)

Training data and model weights will be stored separately.
See `training/README.md` for details on model training pipeline.

## Project Structure

```
ai-models/
├── measurement_model/     # Body measurement AI model
│   ├── api.py            # Flask API service
│   ├── model.py          # Model implementation
│   ├── preprocessing.py  # Image preprocessing
│   └── utils.py          # Utility functions
├── virtual_tryon/        # 3D try-on model (future)
├── tests/                # Unit tests
├── data/                 # Sample data
│   ├── input/           # Test images
│   └── output/          # Results
├── requirements.txt      # Python dependencies
└── README.md            # This file
```

## Development Notes

**MVP Scope:**
- Focus on measurement accuracy
- Support standard body types
- Handle good lighting conditions
- Basic error handling

**Future Enhancements:**
- Support more body types
- Better lighting adaptation
- Real-time processing
- 3D avatar generation
- Virtual garment draping

## Testing

```bash
# Run tests
pytest tests/

# Test with sample images
python measurement_model/test_model.py
```

## License

MIT
