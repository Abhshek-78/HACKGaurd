
# HACKgaurd

HACKgaurd is a browser-based file threat-analysis dashboard backed by a Flask service. It analyzes Portable Executable (PE) import patterns with a trained scikit-learn model, returns a threat score, and presents the result in the dashboard. Non-PE files receive the current fallback scan result.

## Features

- Drag-and-drop or browse-to-upload file scanning.
- PE import extraction with `pefile` and Random Forest model prediction.
- Threat score from `0` to `100` and suspicious-import details.
- Scan history stored in browser `localStorage`.
- TXT report download from the Scan History page.
- Quarantine view for records marked as malware.
- False-positive marking and record deletion.
- Model information and scan settings screens.
- Responsive landing page and dashboard UI.

## Architecture

```text
Browser
  |
  | HTML/CSS/JavaScript
  |-- index.html          Landing page and platform stats
  |-- dashboard.html      Upload, scan progress, and result display
  |-- history.html        Local history and TXT report export
  |-- quarantine.html     Malware-filtered history view
  |-- settings.html       Local settings and model metadata
  |
  | POST /scan (multipart/form-data: file)
  | GET  /info
  v
Flask API (backend/app.py, localhost:5000)
  |-- Loads sentinel_model.pkl and features_list.pkl
  |-- Parses PE files with pefile
  |-- Builds the top-import feature vector
  |-- Returns JSON scan results
```

The Flask application serves the `frontend/` directory as static files. The browser sends scan requests to `http://localhost:5000`. Scan history and settings are client-side only; there is currently no database, authentication service, server-side quarantine storage, or report API.

## Project Structure

```text
HACKgaurd/
|-- backend/
|   |-- app.py                  Flask API and model inference
|   |-- requirements.txt        Python dependencies
|   |-- train_model.py          Model training utility
|   |-- verify_fix.py           Verification utility
|   |-- debug_scan.py           Scan debugging utility
|   |-- debug_zero.py           Zero-score debugging utility
|   |-- sentinel_model.pkl      Trained model artifact
|   |-- features_list.pkl       Model feature names
|   `-- top_1000_pe_imports.csv Training feature data
|-- frontend/
|   |-- index.html              Landing page
|   |-- dashboard.html          Scan dashboard
|   |-- history.html            Scan history and report download
|   |-- quarantine.html         Quarantine view
|   |-- settings.html           Settings and model information
|   |-- dashboard.js             Upload and result workflow
|   |-- script.js                Landing-page interactions
|   |-- style.css                Shared styles
|   |-- dashboard.css            Dashboard styles
|   `-- js/                      Shared page logic and local state
|-- run_sentinel.bat             Windows launcher
`-- README.md
```

## Requirements

- Windows with Python 3.9 or newer recommended.
- A modern browser with JavaScript enabled.
- Python packages listed in `backend/requirements.txt`.
- The model artifacts `backend/sentinel_model.pkl` and `backend/features_list.pkl`.

## Installation

From the project root, create and activate a virtual environment, then install the backend dependencies:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r backend\requirements.txt
```

If PowerShell blocks activation, run the commands from Command Prompt or activate the environment using its available shell script. The repository already contains the trained model files. To retrain, use `backend/train_model.py` and keep the generated model and feature files in `backend/`.

## Run the Application

### Windows launcher

Double-click `run_sentinel.bat`, or run it from a terminal:

```powershell
.\run_sentinel.bat
```

The launcher starts Flask on port `5000` and opens `http://localhost:5000/index.html`. Keep the backend window open while using the dashboard.

### Manual start

```powershell
cd backend
python app.py
```

Then open `http://localhost:5000/index.html` in a browser. The root URL also opens the dashboard at `/`.

## API Endpoints

### `GET /`

Returns the dashboard page served from `frontend/dashboard.html`.

### `GET /info`

Returns model metadata:

```json
{
  "version": "v1.0.0-beta",
  "accuracy": "97.87%",
  "last_trained": "2026-02-17"
}
```

### `POST /scan`

Uploads one file using `multipart/form-data` with the field name `file`.

PowerShell example:

```powershell
curl.exe -X POST -F "file=@C:\path\to\sample.exe" http://localhost:5000/scan
```

Successful response:

```json
{
  "is_malware": false,
  "threat_score": 5,
  "detected_imports": ["Non-Executable File", "Basic Scan Performed"]
}
```

Possible error responses include `400` for a missing or empty file and `500` when the model cannot be loaded or analysis fails.

## Scan Flow

1. The dashboard creates a `FormData` request and posts the selected file to `/scan`.
2. The backend checks known demonstration filenames, then attempts PE parsing.
3. For a PE file, imported APIs are compared with `features_list.pkl` and passed to the trained model.
4. The backend returns the malware flag, probability-based score, and up to ten matching imports.
5. The dashboard stores the result in `localStorage` under `sentinel_scan_history`.
6. History can be searched and exported as a TXT report branded `Generated by HACKgaurd`.
7. Quarantine displays records whose `is_malware` value is `true`; marking a false positive updates the local record.

## Important Limitations

- This is a local prototype. It has no user authentication, authorization, database, audit log, or server-side quarantine.
- CORS is enabled for all origins for local development.
- The dashboard currently targets `http://localhost:5000` directly in JavaScript.
- Non-PE files use a low-risk fallback result and are not deeply analyzed.
- Several filenames such as `ransomware`, `trojan`, `eicartest`, and `safe_sample` intentionally return demonstration results. Do not interpret those results as production detection.
- Uploaded files are analyzed in memory and are not persisted by the backend.

## Troubleshooting

- **Model not loaded:** confirm both `.pkl` files exist in `backend/` and reinstall the Python dependencies.
- **Network error in the dashboard:** confirm Flask is running on port `5000` and that the browser is using the same URL.
- **No history shown:** history is stored per browser origin. Use the same browser and address that performed the scan; clearing site data removes it.
- **Port already in use:** stop the other service using port `5000`, or update the Flask port and the frontend API URLs together.

## License

No license file is currently included in this repository.

---

Generated by HACKgaurd Dev Team
=======
# HACKGaurd

