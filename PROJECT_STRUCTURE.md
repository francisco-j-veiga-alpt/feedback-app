PROJECT_ROOT/\
├── .azure/                          # Azure-specific configuration (managed by azd, do not edit manually often)\
│   └── <environment_name>/          # Configuration for a specific azd environment (e.g., dev, prod)\
│       ├── .env                     # Environment variables for this specific Azure environment\
│       └── config.json              # azd environment configuration\
├── .github/                         # GitHub Actions workflows for CI/CD (optional, but recommended)\
│   └── workflows/\
│       └── azure-dev.yml            # Default azd workflow for deploying to Azure\
├── .devcontainer/                   # Dev container configuration for VS Code Remote - Containers\
│   ├── devcontainer.json            # Main configuration file for the dev container\
│   ├── docker-compose.yml           # Docker Compose file for multi-container setups\
│   ├── Dockerfile                   # Dockerfile to build the app service dev container image\
│   └── mongo.env                    # Environment variables for the MongoDB container\
├── .vscode/                         # VS Code editor configurations and debugging setups\
│   ├── launch.json                  # Debugger configurations (e.g., for Python API, React app)\
│   ├── settings.json                # Workspace-specific settings (e.g., Python interpreter, linters)\
│   └── extensions.json              # Recommended VS Code extensions for the project\
├── infra/                           # Infrastructure-as-Code (IaC) files\
│   ├── main.bicep                   # Main Bicep file defining all Azure resources\
│   ├── main.parameters.json         # Default parameters for the main Bicep file\
│   └── modules/                     # Reusable Bicep modules (e.g., app service, database, storage)\
│       ├── appservice.bicep\
│       ├── containerapp.bicep       # If using Azure Container Apps\
│       └── ...\
├── src/                             # Source code for your application services\
│   ├── api/                         # Python FastAPI backend service\
│   │   ├── app/                     # Main application logic\
│   │   │   ├── __init__.py\
│   │   │   ├── main.py              # FastAPI app definition, routers, and core logic\
│   │   │   ├── routers/             # API route modules (e.g., users.py, items.py)\
│   │   │   │   ├── __init__.py\
│   │   │   │   └── items_router.py  # Example router for items\
│   │   │   ├── schemas/             # Pydantic schemas for request/response validation\
│   │   │   │   ├── __init__.py\
│   │   │   │   └── item_schema.py   # Example Pydantic schema\
│   │   │   └── core/                # Core logic, configurations, dependencies\
│   │   │       ├── __init__.py\
│   │   │       └── config.py        # Application settings\
│   │   ├── tests/                   # Backend unit and integration tests\
│   │   │   ├── __init__.py\
│   │   │   └── test_items_router.py\
│   │   ├── .env.example             # Example environment variables for local backend development\
│   │   ├── .gitignore               # Gitignore specific to the backend\
│   │   ├── Dockerfile               # Dockerfile to containerize the FastAPI backend\
│   │   ├── requirements.txt         # Python dependencies for the backend\
│   │   └── uvicorn.config.json      # Uvicorn server configuration (optional)\
│   └── web/                         # React frontend service (Vite)\
│       ├── public/                  # Static assets (favicon, robots.txt, etc.)\
│       │   └── vite.svg\
│       ├── src/                     # Frontend source code\
│       │   ├── assets/              # Images, fonts, etc.\
│       │   │   └── react.svg\
│       │   ├── components/          # Reusable React components\
│       │   │   └── HelloWorld.jsx\
│       │   ├── hooks/               # Custom React hooks\
│       │   ├── pages/               # Page-level components\
│       │   │   └── HomePage.jsx\
│       │   ├── services/            # API service integrations (e.g., functions to call the backend)\
│       │   │   └── apiService.js\
│       │   ├── App.jsx              # Main App component (routing, layout)\
│       │   ├── index.css            # Global styles or entry point for CSS modules\
│       │   └── main.jsx             # Entry point for the React application\
│       ├── .env.example             # Example environment variables for local frontend development\
│       ├── .gitignore               # Gitignore specific to the frontend\
│       ├── Dockerfile               # Dockerfile to containerize the React frontend (optional, if serving via Nginx or similar)\
│       ├── index.html               # Main HTML file for Vite\
│       ├── package.json             # Frontend dependencies and npm/yarn scripts\
│       ├── vite.config.js           # Vite configuration file\
│       └── README.md                # README specific to the frontend\
├── .env                             # Root .env file for azd to load environment variables for local run (`azd up`)\
├── .gitignore                       # Project-level gitignore (node_modules, __pycache__, .DS_Store, etc.)\
├── azure.yaml                       # Azure Developer CLI manifest file (defines services, hooks, and deployment targets)\
└── README.md                        # Project-level README with setup, deployment instructions, etc.\

---

### Key Files and Folders Explained:

* **`PROJECT_ROOT/`**: The main directory for your entire application.
* **`.azure/`**: Created and managed by `azd`. It stores environment-specific configurations and the `.env` file that `azd` provisions with connection strings, etc., after deploying resources.
* **`.github/workflows/`**: Contains GitHub Actions workflow files. `azd init` can generate a default `azure-dev.yml` for CI/CD.
* **`.vscode/`**: VS Code specific settings to enhance the development experience.
    * **`launch.json`**: Defines debugger configurations. You would typically have entries here to:
        * Launch and debug the Python FastAPI backend (e.g., using the Python debugger configuration, often type `python`, request `launch`, module `uvicorn`, with args pointing to `src.api.app.main:app --reload --port 8000`).
        * Launch and debug the React Vite frontend (e.g., using a JavaScript debugger configuration for Chrome or Edge, type `pwa-chrome` or `pwa-msedge`, request `launch`, with `webRoot` pointing to `${workspaceFolder}/src/web` and `url` to Vite's dev server, typically `http://localhost:5173`).
    * **`settings.json`**: Workspace-specific VS Code settings. This can include things like specifying the Python interpreter path (e.g., `${workspaceFolder}/.venv/bin/python`), default linter and formatter settings (e.g., for Pylint, Black, Prettier, ESLint), Python analysis extra paths (e.g. `["./src/api"]`), and other editor preferences to ensure consistency across the team.
    * **`extensions.json`**: Contains a list of recommended VS Code extensions for the project. This helps new developers quickly set up their environment with the right tools (e.g., `ms-python.python`, `ms-python.pylance`, `dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`, `ms-azuretools.vscode-bicep`, `humao.rest-client` for testing API endpoints).
* **`infra/`**:
    * Holds your Bicep (or Terraform) files that define the Azure resources your application needs.
    * `main.bicep` is the entry point for your infrastructure definition.
    * `main.parameters.json` provides default parameter values for your Bicep templates.
    * `modules/` can contain reusable Bicep modules for better organization.
* **`src/`**: Contains the source code for your application's services.
    * **`src/api/`**: Your FastAPI backend.
        * `app/`: The core Python application.
            * `main.py`: Defines the FastAPI application instance, includes routers, and can contain middleware.
            * `routers/`: Organizes your API endpoints into different files.
            * `schemas/`: Pydantic models for data validation and serialization.
            * `core/`: For shared logic, configuration loading, etc.
        * `tests/`: Contains tests for your backend.
        * `Dockerfile`: Defines how to build a Docker container for your backend.
        * `requirements.txt`: Lists Python package dependencies.
    * **`src/web/`**: Your React frontend application, initialized with Vite.
        * Standard Vite project structure.
        * `Dockerfile` (optional): If you want to containerize your frontend.
* **`.env`**: (At the root) `azd` uses this file to inject environment variables for local development.
* **`azure.yaml`**: The Azure Developer CLI manifest file.
* **`README.md`**: Project-level README.

### How `azd` uses this structure:

1.  **`azd init`**: Initializes a new application.
2.  **`azd up`**:
    * **`azd provision`**: Creates/updates Azure resources via `infra/main.bicep`.
    * **`azd deploy`**: Deploys services based on `azure.yaml` definitions.
3.  **`azure.yaml`**: Guides `azd` on how to find, build, and deploy each service.

