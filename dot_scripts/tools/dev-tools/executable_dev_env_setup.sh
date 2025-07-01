#!/bin/bash
# dev_env_setup.sh - Quickly set up language-specific development environments

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Projects directory
PROJECTS_DIR="${HOME}/Projects"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to print a section header
print_header() {
  echo -e "\n${BLUE}${1}${NC}"
  echo -e "${CYAN}$(printf '=%.0s' $(seq 1 50))${NC}"
}

# Node.js setup
setup_node() {
  local version="${1:-lts}"
  print_header "Setting up Node.js environment ($version)"
  
  # Check if Node.js is already installed
  if command_exists node; then
    local current_version=$(node -v)
    echo -e "${GREEN}Node.js ${current_version} is already installed${NC}"
  else
    echo -e "${YELLOW}Node.js not found. Installing...${NC}"
    
    # Check if nvm is installed
    if ! command_exists nvm; then
      if [ -f "${HOME}/.nvm/nvm.sh" ]; then
        echo -e "${YELLOW}NVM found but not in PATH. Loading...${NC}"
        export NVM_DIR="${HOME}/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      else
        echo -e "${YELLOW}NVM not found. Installing...${NC}"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        export NVM_DIR="${HOME}/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      fi
    fi
    
    echo -e "${GREEN}Installing Node.js $version...${NC}"
    nvm install "$version"
    nvm use "$version"
    nvm alias default "$version"
  fi
  
  # Create project directory
  mkdir -p "${PROJECTS_DIR}/node"
  
  # Ask to initialize a new project
  echo -e "\n${CYAN}Would you like to initialize a new Node.js project? (y/n):${NC}"
  read -p "> " init_project
  if [[ $init_project =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Enter project name:${NC}"
    read -p "> " project_name
    
    if [ -z "$project_name" ]; then
      project_name="node-project-$(date +%Y%m%d)"
      echo -e "${YELLOW}No name provided. Using default: $project_name${NC}"
    fi
    
    local project_dir="${PROJECTS_DIR}/node/${project_name}"
    
    # Check if project directory already exists
    if [ -d "$project_dir" ]; then
      echo -e "${YELLOW}Directory already exists. Choose a different name or delete the existing directory.${NC}"
      return 1
    fi
    
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Initialize npm project
    echo -e "${GREEN}Initializing npm project...${NC}"
    npm init -y
    
    # Modify package.json
    sed -i 's/"name": ".*"/"name": "'"$project_name"'"/' package.json
    
    # Install common tools
    echo -e "\n${CYAN}Select project type:${NC}"
    echo "1) Basic Node.js project"
    echo "2) Express web server"
    echo "3) React application"
    echo "4) TypeScript Node.js project"
    read -p "> " project_type
    
    case $project_type in
      2)
        # Express server
        echo -e "${GREEN}Setting up Express web server...${NC}"
        npm install express cors morgan dotenv
        npm install --save-dev nodemon
        
        # Create basic directory structure
        mkdir -p src/{controllers,routes,models,config}
        
        # Create index.js
        cat > src/index.js << 'EOF'
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'API is running' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF
        
        # Create .env file
        cat > .env << 'EOF'
PORT=3000
NODE_ENV=development
EOF
        
        # Create .gitignore
        cat > .gitignore << 'EOF'
node_modules/
.env
npm-debug.log
.DS_Store
coverage/
.nyc_output/
dist/
EOF
        
        # Update package.json scripts
        node -e "
          const pkg = require('./package.json');
          pkg.scripts = {
            ...pkg.scripts,
            start: 'node src/index.js',
            dev: 'nodemon src/index.js'
          };
          fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
        "
        ;;
        
      3)
        # React application
        echo -e "${GREEN}Setting up React application...${NC}"
        npm install -g create-react-app
        cd ..
        npx create-react-app "$project_name"
        cd "$project_name"
        npm install axios react-router-dom
        ;;
        
      4)
        # TypeScript Node.js
        echo -e "${GREEN}Setting up TypeScript Node.js project...${NC}"
        npm install typescript @types/node ts-node
        npm install --save-dev nodemon
        
        # Create tsconfig.json
        npx tsc --init --target ES2020 --module commonjs --outDir dist --rootDir src --esModuleInterop --resolveJsonModule --strict
        
        # Create src directory with index.ts
        mkdir -p src
        cat > src/index.ts << 'EOF'
class Greeter {
  private name: string;

  constructor(name: string) {
    this.name = name;
  }

  greet(): string {
    return `Hello, ${this.name}!`;
  }
}

const greeter = new Greeter('World');
console.log(greeter.greet());
EOF
        
        # Create .gitignore
        cat > .gitignore << 'EOF'
node_modules/
dist/
.env
npm-debug.log
.DS_Store
coverage/
.nyc_output/
EOF
        
        # Update package.json scripts
        node -e "
          const pkg = require('./package.json');
          pkg.scripts = {
            ...pkg.scripts,
            build: 'tsc',
            start: 'node dist/index.js',
            dev: 'nodemon --exec ts-node src/index.ts'
          };
          fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
        "
        ;;
        
      *)
        # Basic Node.js project
        echo -e "${GREEN}Setting up basic Node.js project...${NC}"
        
        # Create index.js
        cat > index.js << 'EOF'
console.log('Hello, world!');

// Example function
function greet(name) {
  return `Hello, ${name}!`;
}

console.log(greet('Node.js'));
EOF
        
        # Create .gitignore
        cat > .gitignore << 'EOF'
node_modules/
.env
npm-debug.log
.DS_Store
EOF
        
        # Update package.json scripts
        node -e "
          const pkg = require('./package.json');
          pkg.scripts = {
            ...pkg.scripts,
            start: 'node index.js'
          };
          fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
        "
        ;;
    esac
    
    # Ask to install development tools
    echo -e "\n${CYAN}Install ESLint and Prettier for code quality? (y/n):${NC}"
    read -p "> " install_tools
    if [[ $install_tools =~ ^[Yy]$ ]]; then
      npm install --save-dev eslint prettier eslint-config-prettier eslint-plugin-prettier
      
      # Create ESLint config
      cat > .eslintrc.json << 'EOF'
{
  "env": {
    "node": true,
    "es6": true
  },
  "extends": [
    "eslint:recommended",
    "prettier"
  ],
  "plugins": ["prettier"],
  "rules": {
    "prettier/prettier": "error",
    "no-console": "off"
  },
  "parserOptions": {
    "ecmaVersion": 2020
  }
}
EOF
      
      # Create Prettier config
      cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2
}
EOF
      
      # Add format script to package.json
      node -e "
        const pkg = require('./package.json');
        pkg.scripts = {
          ...pkg.scripts,
          format: 'prettier --write \"**/*.{js,jsx,ts,tsx,json,md}\"',
          lint: 'eslint .'
        };
        fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
      "
    fi
    
    # Initialize git repository
    echo -e "\n${CYAN}Initialize Git repository? (y/n):${NC}"
    read -p "> " init_git
    if [[ $init_git =~ ^[Yy]$ ]]; then
      git init
      git add .
      git commit -m "Initial commit"
    fi
    
    echo -e "\n${GREEN}✅ Project initialized at $project_dir${NC}"
    echo -e "\nRun the following commands to get started:"
    echo -e "${CYAN}cd $project_dir${NC}"
    
    if [ "$project_type" == "3" ]; then
      echo -e "${CYAN}npm start${NC}"
    elif [ "$project_type" == "4" ]; then
      echo -e "${CYAN}npm run dev${NC}"
    elif [ "$project_type" == "2" ]; then
      echo -e "${CYAN}npm run dev${NC}"
    else
      echo -e "${CYAN}npm start${NC}"
    fi
  fi
  
  echo -e "\n${GREEN}✅ Node.js environment setup complete!${NC}"
  node --version
  npm --version
}

# Python setup
setup_python() {
  local version="${1:-3}"
  print_header "Setting up Python environment"
  
  # Check if Python is already installed
  if command_exists python$version; then
    local current_version=$(python$version --version)
    echo -e "${GREEN}${current_version} is already installed${NC}"
  else
    echo -e "${YELLOW}Python $version not found. Installing...${NC}"
    if command_exists apt; then
      sudo apt update && sudo apt install -y python$version python$version-venv python$version-dev
    elif command_exists dnf; then
      sudo dnf install -y python$version python$version-devel
    elif command_exists brew; then
      brew install python@$version
    else
      echo -e "${RED}Unable to install Python automatically. Please install manually.${NC}"
      exit 1
    fi
  fi
  
  # Create project directory
  mkdir -p "${PROJECTS_DIR}/python"
  
  # Ask to initialize a new project
  echo -e "\n${CYAN}Would you like to initialize a new Python project? (y/n):${NC}"
  read -p "> " init_project
  if [[ $init_project =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Enter project name:${NC}"
    read -p "> " project_name
    
    if [ -z "$project_name" ]; then
      project_name="python-project-$(date +%Y%m%d)"
      echo -e "${YELLOW}No name provided. Using default: $project_name${NC}"
    fi
    
    local project_dir="${PROJECTS_DIR}/python/${project_name}"
    
    # Check if project directory already exists
    if [ -d "$project_dir" ]; then
      echo -e "${YELLOW}Directory already exists. Choose a different name or delete the existing directory.${NC}"
      return 1
    fi
    
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Create virtual environment
    echo -e "${GREEN}Creating virtual environment...${NC}"
    python$version -m venv venv
    source venv/bin/activate
    
    # Upgrade pip and install setuptools
    pip install --upgrade pip setuptools wheel
    
    # Ask about project type
    echo -e "\n${CYAN}Select project type:${NC}"
    echo "1) Basic script"
    echo "2) Flask web app"
    echo "3) FastAPI web app"
    echo "4) Data science (numpy, pandas, matplotlib)"
    echo "5) Django web app"
    read -p "> " project_type
    
    case $project_type in
      2)
        # Flask web app
        echo -e "${GREEN}Setting up Flask web app...${NC}"
        pip install flask python-dotenv flask-sqlalchemy flask-migrate flask-wtf
        
        # Create project structure
        mkdir -p app/{static/{css,js,img},templates,models,routes}
        
        # Create basic app files
        cat > app/__init__.py << 'EOF'
from flask import Flask
from config import Config

app = Flask(__name__)
app.config.from_object(Config)

from app import routes, models
EOF
        
        cat > app/routes.py << 'EOF'
from flask import render_template
from app import app

@app.route('/')
@app.route('/index')
def index():
    return render_template('index.html', title='Home')
EOF
        
        cat > app/templates/base.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{% if title %}{{ title }} - Flask App{% else %}Flask App{% endif %}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
</head>
<body>
    <header>
        <nav>
            <a href="{{ url_for('index') }}">Home</a>
        </nav>
    </header>
    
    <main>
        {% block content %}{% endblock %}
    </main>
    
    <footer>
        <p>&copy; {{ now.year }} Flask App</p>
    </footer>
</body>
</html>
EOF
        
        cat > app/templates/index.html << 'EOF'
{% extends "base.html" %}

{% block content %}
    <h1>Welcome to Flask!</h1>
    <p>This is a starter Flask application.</p>
{% endblock %}
EOF
        
        cat > app/static/css/style.css << 'EOF'
body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    margin: 0;
    padding: 0;
    color: #333;
}

header {
    background-color: #4285f4;
    padding: 1rem;
}

nav a {
    color: white;
    text-decoration: none;
    margin-right: 1rem;
}

main {
    padding: 2rem;
    max-width: 800px;
    margin: 0 auto;
}

footer {
    text-align: center;
    padding: 1rem;
    background-color: #f5f5f5;
    margin-top: 2rem;
}
EOF
        
        cat > config.py << 'EOF'
import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-key-please-change-in-production'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///app.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
EOF
        
        cat > run.py << 'EOF'
from app import app
import datetime

@app.context_processor
def inject_now():
    return {'now': datetime.datetime.now()}

if __name__ == '__main__':
    app.run(debug=True)
EOF
        
        pip freeze > requirements.txt
        ;;
        
      3)
        # FastAPI web app
        echo -e "${GREEN}Setting up FastAPI web app...${NC}"
        pip install fastapi uvicorn[standard] pydantic sqlalchemy
        
        # Create project structure
        mkdir -p app/{models,routers,schemas,core}
        
        # Create basic app files
        cat > app/__init__.py << 'EOF'
# app/__init__.py
EOF
        
        cat > app/main.py << 'EOF'
from fastapi import FastAPI
from app.routers import items, users

app = FastAPI(
    title="FastAPI App",
    description="A sample FastAPI application",
    version="0.1.0",
)

app.include_router(items.router)
app.include_router(users.router)

@app.get("/")
async def root():
    return {"message": "Welcome to FastAPI!"}
EOF
        
        cat > app/routers/__init__.py << 'EOF'
# app/routers/__init__.py
EOF
        
        cat > app/routers/items.py << 'EOF'
from fastapi import APIRouter, HTTPException
from typing import List
from app.schemas.item import Item, ItemCreate

router = APIRouter(
    prefix="/items",
    tags=["items"],
    responses={404: {"description": "Not found"}},
)

# Mock database
items_db = []

@router.get("/", response_model=List[Item])
async def read_items():
    return items_db

@router.post("/", response_model=Item)
async def create_item(item: ItemCreate):
    new_item = Item(id=len(items_db) + 1, **item.dict())
    items_db.append(new_item)
    return new_item

@router.get("/{item_id}", response_model=Item)
async def read_item(item_id: int):
    if item_id < 0 or item_id >= len(items_db):
        raise HTTPException(status_code=404, detail="Item not found")
    return items_db[item_id]
EOF
        
        cat > app/routers/users.py << 'EOF'
from fastapi import APIRouter, HTTPException
from typing import List
from app.schemas.user import User, UserCreate

router = APIRouter(
    prefix="/users",
    tags=["users"],
    responses={404: {"description": "Not found"}},
)

# Mock database
users_db = []

@router.get("/", response_model=List[User])
async def read_users():
    return users_db

@router.post("/", response_model=User)
async def create_user(user: UserCreate):
    new_user = User(id=len(users_db) + 1, **user.dict())
    users_db.append(new_user)
    return new_user

@router.get("/{user_id}", response_model=User)
async def read_user(user_id: int):
    if user_id < 0 or user_id >= len(users_db):
        raise HTTPException(status_code=404, detail="User not found")
    return users_db[user_id]
EOF
        
        mkdir -p app/schemas
        cat > app/schemas/__init__.py << 'EOF'
# app/schemas/__init__.py
EOF
        
        cat > app/schemas/item.py << 'EOF'
from pydantic import BaseModel

class ItemBase(BaseModel):
    title: str
    description: str = None

class ItemCreate(ItemBase):
    pass

class Item(ItemBase):
    id: int
    
    class Config:
        orm_mode = True
EOF
        
        cat > app/schemas/user.py << 'EOF'
from pydantic import BaseModel, EmailStr

class UserBase(BaseModel):
    email: str
    name: str = None

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    
    class Config:
        orm_mode = True
EOF
        
        cat > main.py << 'EOF'
import uvicorn
from app.main import app

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
EOF
        
        pip freeze > requirements.txt
        ;;
        
      4)
        # Data science
        echo -e "${GREEN}Setting up data science environment...${NC}"
        pip install numpy pandas matplotlib seaborn jupyter scikit-learn
        
        # Create project structure
        mkdir -p data notebooks src
        
        # Create sample notebook
        cat > notebooks/sample_analysis.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Sample Data Analysis\n",
    "\n",
    "This notebook demonstrates basic data analysis with pandas and matplotlib."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "import numpy as np\n",
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "\n",
    "# Set plot style\n",
    "sns.set(style=\"whitegrid\")\n",
    "plt.rcParams[\"figure.figsize\"] = (12, 8)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Generate Sample Data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Generate random data\n",
    "np.random.seed(42)\n",
    "data = {\n",
    "    'x': np.random.normal(0, 1, 1000),\n",
    "    'y': np.random.normal(0, 1, 1000),\n",
    "    'group': np.random.choice(['A', 'B', 'C'], 1000)\n",
    "}\n",
    "\n",
    "df = pd.DataFrame(data)\n",
    "df.head()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Data Visualization"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Create a scatter plot\n",
    "plt.figure(figsize=(12, 8))\n",
    "sns.scatterplot(data=df, x='x', y='y', hue='group')\n",
    "plt.title('Sample Scatter Plot')\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Create a histogram\n",
    "plt.figure(figsize=(12, 8))\n",
    "sns.histplot(data=df, x='x', hue='group', kde=True)\n",
    "plt.title('Distribution of X by Group')\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Statistical Analysis"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Summary statistics\n",
    "df.describe()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Group statistics\n",
    "df.groupby('group').agg(['mean', 'std', 'count'])"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.8.5"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF
        
        cat > src/data_loader.py << 'EOF'
import pandas as pd
import numpy as np
import os

def load_sample_data(n_samples=1000, random_state=42):
    """
    Generate a sample dataset.
    
    Parameters:
    -----------
    n_samples : int
        Number of samples to generate
    random_state : int
        Random seed for reproducibility
        
    Returns:
    --------
    pd.DataFrame
        DataFrame with sample data
    """
    np.random.seed(random_state)
    
    data = {
        'x': np.random.normal(0, 1, n_samples),
        'y': np.random.normal(0, 1, n_samples),
        'group': np.random.choice(['A', 'B', 'C'], n_samples)
    }
    
    return pd.DataFrame(data)

def save_data(df, filename, output_dir='data'):
    """
    Save a DataFrame to CSV.
    
    Parameters:
    -----------
    df : pd.DataFrame
        DataFrame to save
    filename : str
        Name of the file
    output_dir : str
        Directory to save the file
    """
    os.makedirs(output_dir, exist_ok=True)
    path = os.path.join(output_dir, filename)
    df.to_csv(path, index=False)
    print(f"Data saved to {path}")

if __name__ == "__main__":
    # Example usage
    df = load_sample_data(n_samples=1000)
    save_data(df, 'sample_data.csv')
EOF
        
        cat > README.md << 'EOF'
# Data Science Project

This is a data science project template with basic structure and tools.

## Setup

1. Create a virtual environment:
   ```
   python -m venv venv
   ```

2. Activate the virtual environment:
   ```
   source venv/bin/activate   # On Linux/Mac
   venv\Scripts\activate      # On Windows
   ```

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

## Project Structure

- `data/`: Data files
- `notebooks/`: Jupyter notebooks for analysis
- `src/`: Python source code
- `README.md`: Project documentation

## Running Jupyter Notebooks

```
jupyter notebook notebooks/
```
EOF
        
        pip freeze > requirements.txt
        ;;
        
      5)
        # Django web app
        echo -e "${GREEN}Setting up Django web app...${NC}"
        pip install django django-crispy-forms django-environ
        
        # Create Django project
        django-admin startproject config .
        python manage.py startapp core
        
        # Update settings
        sed -i 's/INSTALLED_APPS = \[/INSTALLED_APPS = [\n    "core",/' config/settings.py
        
        # Create basic app structure
        mkdir -p core/{templates/core,static/core/{css,js}}
        
        # Create base template
        cat > core/templates/core/base.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}Django App{% endblock %}</title>
    {% load static %}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="{% static 'core/css/style.css' %}">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="{% url 'home' %}">Django App</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="{% url 'home' %}">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{% url 'about' %}">About</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <main class="container mt-4">
        {% block content %}{% endblock %}
    </main>

    <footer class="bg-light text-center p-4 mt-5">
        <div class="container">
            <p class="mb-0">&copy; {% now "Y" %} Django App</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="{% static 'core/js/main.js' %}"></script>
</body>
</html>
EOF
        
        # Create home template
        cat > core/templates/core/home.html << 'EOF'
{% extends 'core/base.html' %}

{% block title %}Home - Django App{% endblock %}

{% block content %}
<div class="jumbotron py-5">
    <h1 class="display-4">Welcome to Django!</h1>
    <p class="lead">This is a simple Django application to get you started.</p>
    <hr class="my-4">
    <p>Use this template as a starting point for your Django projects.</p>
    <a class="btn btn-primary btn-lg" href="{% url 'about' %}" role="button">Learn more</a>
</div>
{% endblock %}
EOF
        
        # Create about template
        cat > core/templates/core/about.html << 'EOF'
{% extends 'core/base.html' %}

{% block title %}About - Django App{% endblock %}

{% block content %}
<h1>About</h1>
<p>This is a Django starter application.</p>
<p>Use this as a template for your Django projects.</p>
{% endblock %}
EOF
        
        # Create CSS file
        cat > core/static/core/css/style.css << 'EOF'
/* Custom styles */
body {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

main {
    flex-grow: 1;
}
EOF
        
        # Create JavaScript file
        cat > core/static/core/js/main.js << 'EOF'
// Custom JavaScript
console.log('Django app loaded');
EOF
        
        # Update views.py
        cat > core/views.py << 'EOF'
from django.shortcuts import render

def home(request):
    return render(request, 'core/home.html')

def about(request):
    return render(request, 'core/about.html')
EOF
        
        # Create urls.py in core app
        cat > core/urls.py << 'EOF'
from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('about/', views.about, name='about'),
]
EOF
        
        # Update project urls.py
        cat > config/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('core.urls')),
]
EOF
        
        pip freeze > requirements.txt
        
        # Run migrations
        python manage.py migrate
        ;;
        
      *)
        # Basic script
        echo -e "${GREEN}Setting up basic Python script...${NC}"
        
        mkdir -p src
        
        cat > src/main.py << 'EOF'
#!/usr/bin/env python3
"""
Main module for the project.
"""

def greet(name: str) -> str:
    """
    Greet a person.
    
    Args:
        name: The name of the person to greet
        
    Returns:
        A greeting message
    """
    return f"Hello, {name}!"

def main():
    """Main entry point for the application."""
    print(greet("World"))
    
if __name__ == "__main__":
    main()
EOF
        
        # Make main.py executable
        chmod +x src/main.py
        
        # Create setup.py
        cat > setup.py << 'EOF'
from setuptools import setup, find_packages

setup(
    name="python_project",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[],
    author="Your Name",
    author_email="your.email@example.com",
    description="A basic Python project",
    keywords="python, project",
    url="https://github.com/yourusername/project",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Programming Language :: Python :: 3",
    ],
    python_requires=">=3.6",
)
EOF
        
        pip freeze > requirements.txt
        ;;
    esac
    
    # Create README
    if [ ! -f "README.md" ]; then
      cat > README.md << EOF
# $project_name

A Python project.

## Setup

1. Create a virtual environment:
   \`\`\`
   python -m venv venv
   \`\`\`

2. Activate the virtual environment:
   \`\`\`
   source venv/bin/activate   # On Linux/Mac
   venv\\Scripts\\activate     # On Windows
   \`\`\`

3. Install dependencies:
   \`\`\`
   pip install -r requirements.txt
   \`\`\`

## Usage

[Provide usage instructions here]
EOF
    fi
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
venv/
env/
ENV/

# IDE files
.idea/
.vscode/
*.swp
*.swo

# Environment variables
.env

# Django
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal
media/

# Flask
instance/
.webassets-cache

# Jupyter Notebook
.ipynb_checkpoints

# macOS
.DS_Store
EOF
    
    # Initialize git repository
    echo -e "\n${CYAN}Initialize Git repository? (y/n):${NC}"
    read -p "> " init_git
    if [[ $init_git =~ ^[Yy]$ ]]; then
      git init
      git add .
      git commit -m "Initial commit"
    fi
    
    echo -e "\n${GREEN}✅ Project initialized at $project_dir${NC}"
    
    if [ "$project_type" == "2" ]; then
      echo -e "\nRun the following commands to start your Flask app:"
      echo -e "${CYAN}cd $project_dir${NC}"
      echo -e "${CYAN}source venv/bin/activate${NC}"
      echo -e "${CYAN}python run.py${NC}"
    elif [ "$project_type" == "3" ]; then
      echo -e "\nRun the following commands to start your FastAPI app:"
      echo -e "${CYAN}cd $project_dir${NC}"
      echo -e "${CYAN}source venv/bin/activate${NC}"
      echo -e "${CYAN}python main.py${NC}"
      echo -e "\nThen visit: http://localhost:8000/docs for API documentation"
    elif [ "$project_type" == "4" ]; then
      echo -e "\nRun the following commands to start Jupyter:"
      echo -e "${CYAN}cd $project_dir${NC}"
      echo -e "${CYAN}source venv/bin/activate${NC}"
      echo -e "${CYAN}jupyter notebook notebooks/${NC}"
    elif [ "$project_type" == "5" ]; then
      echo -e "\nRun the following commands to start your Django app:"
      echo -e "${CYAN}cd $project_dir${NC}"
      echo -e "${CYAN}source venv/bin/activate${NC}"
      echo -e "${CYAN}python manage.py runserver${NC}"
    else
      echo -e "\nRun the following commands to run your script:"
      echo -e "${CYAN}cd $project_dir${NC}"
      echo -e "${CYAN}source venv/bin/activate${NC}"
      echo -e "${CYAN}python src/main.py${NC}"
    fi
  fi
  
  echo -e "\n${GREEN}✅ Python environment setup complete!${NC}"
  python$version --version
}

# Go setup
setup_go() {
  print_header "Setting up Go environment"
  
  # Check if Go is already installed
  if command_exists go; then
    local current_version=$(go version)
    echo -e "${GREEN}${current_version} is already installed${NC}"
  else
    echo -e "${YELLOW}Go not found. Installing...${NC}"
    if command_exists apt; then
      sudo apt update && sudo apt install -y golang-go
    elif command_exists dnf; then
      sudo dnf install -y golang
    elif command_exists brew; then
      brew install go
    else
      echo -e "${RED}Unable to install Go automatically. Please install manually.${NC}"
      exit 1
    fi
  fi
  
  # Set up GOPATH if not already set
  if [ -z "$GOPATH" ]; then
    export GOPATH=${HOME}/go
    echo 'export GOPATH=$HOME/go' >> ${HOME}/.bashrc
    echo 'export PATH=$PATH:$GOPATH/bin' >> ${HOME}/.bashrc
  fi
  
  mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg"
  
  # Create project directory
  mkdir -p "${PROJECTS_DIR}/go"
  
  # Ask to initialize a new project
  echo -e "\n${CYAN}Would you like to initialize a new Go project? (y/n):${NC}"
  read -p "> " init_project
  if [[ $init_project =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Enter project name:${NC}"
    read -p "> " project_name
    
    if [ -z "$project_name" ]; then
      project_name="go-project-$(date +%Y%m%d)"
      echo -e "${YELLOW}No name provided. Using default: $project_name${NC}"
    fi
    
    # Ask about module path
    echo -e "${CYAN}Enter module path (e.g., github.com/username/${project_name}):${NC}"
    read -p "> " module_path
    
    if [ -z "$module_path" ]; then
      echo -e "${YELLOW}No module path provided. Using example.com/${project_name}${NC}"
      module_path="example.com/${project_name}"
    fi
    
    local project_dir="${PROJECTS_DIR}/go/${project_name}"
    
    # Check if project directory already exists
    if [ -d "$project_dir" ]; then
      echo -e "${YELLOW}Directory already exists. Choose a different name or delete the existing directory.${NC}"
      return 1
    fi
    
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Initialize Go module
    echo -e "${GREEN}Initializing Go module...${NC}"
    go mod init "$module_path"
    
    # Ask about project type
    echo -e "\n${CYAN}Select project type:${NC}"
    echo "1) Basic CLI app"
    echo "2) HTTP server (standard library)"
    echo "3) HTTP server (with Gin framework)"
    echo "4) gRPC service"
    read -p "> " project_type
    
    case $project_type in
      2)
        # HTTP server (standard library)
        echo -e "${GREEN}Setting up HTTP server (standard library)...${NC}"
        
        mkdir -p cmd/$project_name pkg/{handlers,models}
        
        # Create main.go
        cat > cmd/$project_name/main.go << 'EOF'
package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"MODULEPATH/pkg/handlers"
)

func main() {
	var port int
	flag.IntVar(&port, "port", 8080, "Port to listen on")
	flag.Parse()

	// Set up routes
	mux := http.NewServeMux()
	mux.HandleFunc("/", handlers.HomeHandler)
	mux.HandleFunc("/api/health", handlers.HealthCheckHandler)

	// Configure the server
	addr := fmt.Sprintf(":%d", port)
	server := &http.Server{
		Addr:         addr,
		Handler:      handlers.LoggingMiddleware(mux),
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start the server in a goroutine
	go func() {
		fmt.Printf("Server starting on %s\n", addr)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Could not listen on %s: %v\n", addr, err)
		}
	}()

	// Set up graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	fmt.Println("Server shutting down...")
}
EOF
        
        # Create handlers
        cat > pkg/handlers/handlers.go << 'EOF'
package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"time"
)

// Response represents a standard API response
type Response struct {
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// HomeHandler handles the root route
func HomeHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Welcome to the API!\n"))
}

// HealthCheckHandler returns the API health status
func HealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	response := Response{
		Status:  "success",
		Message: "API is healthy",
		Data: map[string]string{
			"version": "1.0.0",
			"time":    time.Now().Format(time.RFC3339),
		},
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

// LoggingMiddleware logs HTTP requests
func LoggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		next.ServeHTTP(w, r)

		log.Printf(
			"%s %s %s %s",
			r.Method,
			r.RequestURI,
			r.RemoteAddr,
			time.Since(start),
		)
	})
}
EOF
        
        # Replace MODULEPATH with the actual module path
        sed -i "s|MODULEPATH|$module_path|g" cmd/$project_name/main.go
        ;;
        
      3)
        # HTTP server (with Gin framework)
        echo -e "${GREEN}Setting up HTTP server (with Gin framework)...${NC}"
        
        mkdir -p cmd/$project_name internal/{api,middleware,models,config}
        
        # Get Gin package
        go get -u github.com/gin-gonic/gin
        
        # Create main.go
        cat > cmd/$project_name/main.go << 'EOF'
package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"MODULEPATH/internal/api"
	"MODULEPATH/internal/config"
)

func main() {
	var port int
	flag.IntVar(&port, "port", 8080, "Port to listen on")
	flag.Parse()

	// Initialize configuration
	cfg := config.Config{
		Port: port,
		Mode: "debug", // Change to "release" for production
	}

	// Initialize router
	router := api.SetupRouter(&cfg)

	// Start the server in a goroutine
	go func() {
		addr := fmt.Sprintf(":%d", cfg.Port)
		fmt.Printf("Server starting on %s\n", addr)
		if err := router.Run(addr); err != nil {
			log.Fatalf("Could not start server: %v\n", err)
		}
	}()

	// Set up graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	fmt.Println("Server shutting down...")
}
EOF
        
        # Create config package
        cat > internal/config/config.go << 'EOF'
package config

// Config holds application configuration
type Config struct {
	Port int
	Mode string
}
EOF
        
        # Create API setup
        cat > internal/api/router.go << 'EOF'
package api

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	
	"MODULEPATH/internal/config"
	"MODULEPATH/internal/middleware"
)

// Response represents a standard API response
type Response struct {
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// SetupRouter configures the Gin router
func SetupRouter(cfg *config.Config) *gin.Engine {
	// Set Gin mode
	gin.SetMode(cfg.Mode)

	router := gin.New()
	
	// Use middleware
	router.Use(gin.Recovery())
	router.Use(middleware.Logger())

	// Routes
	router.GET("/", homeHandler)
	
	// API routes
	api := router.Group("/api")
	{
		api.GET("/health", healthCheckHandler)
	}

	return router
}

func homeHandler(c *gin.Context) {
	c.String(http.StatusOK, "Welcome to the API!")
}

func healthCheckHandler(c *gin.Context) {
	response := Response{
		Status:  "success",
		Message: "API is healthy",
		Data: map[string]string{
			"version": "1.0.0",
			"time":    time.Now().Format(time.RFC3339),
		},
	}

	c.JSON(http.StatusOK, response)
}
EOF
        
        # Create middleware
        cat > internal/middleware/logger.go << 'EOF'
package middleware

import (
	"log"
	"time"

	"github.com/gin-gonic/gin"
)

// Logger returns a gin middleware for logging HTTP requests
func Logger() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Start timer
		start := time.Now()
		path := c.Request.URL.Path
		method := c.Request.Method

		// Process request
		c.Next()

		// Calculate latency
		latency := time.Since(start)
		statusCode := c.Writer.Status()

		log.Printf("[GIN] %s | %3d | %12v | %s | %s",
			method,
			statusCode,
			latency,
			c.ClientIP(),
			path,
		)
	}
}
EOF
        
        # Replace MODULEPATH with the actual module path
        find . -type f -name "*.go" -exec sed -i "s|MODULEPATH|$module_path|g" {} \;
        
        # Update go.mod
        go mod tidy
        ;;
        
      4)
        # gRPC service
        echo -e "${GREEN}Setting up gRPC service...${NC}"
        
        mkdir -p cmd/$project_name pkg/{api,models,service} proto
        
        # Get necessary packages
        go get -u google.golang.org/grpc
        go get -u github.com/golang/protobuf/protoc-gen-go
        go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc
        
        # Create proto file
        cat > proto/service.proto << 'EOF'
syntax = "proto3";
package proto;

option go_package = "MODULEPATH/pkg/api";

// Define a service
service Greeter {
  // Define a method
  rpc SayHello (HelloRequest) returns (HelloResponse) {}
}

// Define request message
message HelloRequest {
  string name = 1;
}

// Define response message
message HelloResponse {
  string message = 1;
}
EOF
        
        # Replace MODULEPATH with the actual module path
        sed -i "s|MODULEPATH|$module_path|g" proto/service.proto
        
        # Create main.go
        cat > cmd/$project_name/main.go << 'EOF'
package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	"google.golang.org/grpc"
	
	"MODULEPATH/pkg/api"
	"MODULEPATH/pkg/service"
)

func main() {
	var port int
	flag.IntVar(&port, "port", 50051, "Port to listen on")
	flag.Parse()

	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", port))
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	// Create gRPC server
	grpcServer := grpc.NewServer()
	
	// Register service
	api.RegisterGreeterServer(grpcServer, &service.GreeterService{})

	// Start the server in a goroutine
	go func() {
		fmt.Printf("gRPC server starting on :%d\n", port)
		if err := grpcServer.Serve(lis); err != nil {
			log.Fatalf("Failed to serve: %v", err)
		}
	}()

	// Set up graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	
	fmt.Println("Server shutting down...")
	grpcServer.GracefulStop()
}
EOF
        
        # Create service implementation
        cat > pkg/service/greeter.go << 'EOF'
package service

import (
	"context"
	"fmt"
	
	"MODULEPATH/pkg/api"
)

// GreeterService implements the Greeter service
type GreeterService struct {
	api.UnimplementedGreeterServer
}

// SayHello implements the SayHello method
func (s *GreeterService) SayHello(ctx context.Context, req *api.HelloRequest) (*api.HelloResponse, error) {
	message := fmt.Sprintf("Hello, %s!", req.Name)
	return &api.HelloResponse{
		Message: message,
	}, nil
}
EOF
        
        # Replace MODULEPATH with the actual module path
        find . -type f -name "*.go" -exec sed -i "s|MODULEPATH|$module_path|g" {} \;
        
        # Add instructions to generate proto files in README
        echo -e "${YELLOW}You need to generate Go code from the protobuf definition.${NC}"
        echo -e "${YELLOW}Install protoc compiler and run:${NC}"
        echo -e "${CYAN}protoc --go_out=. --go-grpc_out=. proto/service.proto${NC}"
        
        # Update go.mod
        go mod tidy
        ;;
        
      *)
        # Basic CLI app
        echo -e "${GREEN}Setting up basic Go CLI app...${NC}"
        
        mkdir -p cmd/$project_name pkg
        
        # Create main.go
        cat > cmd/$project_name/main.go << 'EOF'
package main

import (
	"flag"
	"fmt"
	"os"
)

// Version information
var (
	Version = "0.1.0"
	Build   = "dev"
)

func main() {
	// Parse command line arguments
	versionFlag := flag.Bool("version", false, "Print version information")
	nameFlag := flag.String("name", "World", "Name to greet")
	
	flag.Parse()
	
	// Print version and exit if requested
	if *versionFlag {
		fmt.Printf("%s version %s (build %s)\n", os.Args[0], Version, Build)
		os.Exit(0)
	}
	
	// Print greeting
	fmt.Printf("Hello, %s!\n", *nameFlag)
}
EOF
        ;;
    esac
    
    # Create README.md
    cat > README.md << EOF
# $project_name

A Go project.

## Setup

1. Clone this repository:
   \`\`\`
   git clone <repository-url>
   cd $project_name
   \`\`\`

2. Build the project:
   \`\`\`
   go build ./cmd/$project_name
   \`\`\`

3. Run the project:
   \`\`\`
   ./$project_name
   \`\`\`

## Usage

[Provide usage instructions here]
EOF
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with `go test -c`
*.test

# Output of the go coverage tool
*.out

# Dependency directories
vendor/

# Build output
bin/
dist/

# IDE files
.idea/
.vscode/
*.swp
*.swo

# macOS
.DS_Store
EOF
    
    # Initialize git repository
    echo -e "\n${CYAN}Initialize Git repository? (y/n):${NC}"
    read -p "> " init_git
    if [[ $init_git =~ ^[Yy]$ ]]; then
      git init
      git add .
      git commit -m "Initial commit"
    fi
    
    echo -e "\n${GREEN}✅ Project initialized at $project_dir${NC}"
    echo -e "\nRun the following commands to build and run your project:"
    echo -e "${CYAN}cd $project_dir${NC}"
    echo -e "${CYAN}go build ./cmd/$project_name${NC}"
    echo -e "${CYAN}./$project_name${NC}"
  fi
  
  echo -e "\n${GREEN}✅ Go environment setup complete!${NC}"
  go version
}

# Rust setup
setup_rust() {
  print_header "Setting up Rust environment"
  
  # Check if Rust is already installed
  if command_exists rustc; then
    local current_version=$(rustc --version)
    echo -e "${GREEN}${current_version} is already installed${NC}"
  else
    echo -e "${YELLOW}Rust not found. Installing...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
  fi
  
  # Create project directory
  mkdir -p "${PROJECTS_DIR}/rust"
  
  # Ask to initialize a new project
  echo -e "\n${CYAN}Would you like to initialize a new Rust project? (y/n):${NC}"
  read -p "> " init_project
  if [[ $init_project =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Enter project name:${NC}"
    read -p "> " project_name
    
    if [ -z "$project_name" ]; then
      project_name="rust-project-$(date +%Y%m%d)"
      echo -e "${YELLOW}No name provided. Using default: $project_name${NC}"
    fi
    
    # Check project name validity
    if ! [[ $project_name =~ ^[a-z0-9_-]+$ ]]; then
      echo -e "${RED}Error: Project name must contain only lowercase letters, numbers, underscores, and hyphens.${NC}"
      return 1
    fi
    
    local project_dir="${PROJECTS_DIR}/rust/${project_name}"
    
    # Check if project directory already exists
    if [ -d "$project_dir" ]; then
      echo -e "${YELLOW}Directory already exists. Choose a different name or delete the existing directory.${NC}"
      return 1
    fi
    
    # Ask about project type
    echo -e "\n${CYAN}Select project type:${NC}"
    echo "1) Binary (application)"
    echo "2) Library"
    echo "3) Web application (with Rocket)"
    echo "4) Command line tool (with clap)"
    read -p "> " project_type
    
    case $project_type in
      2)
        # Library
        echo -e "${GREEN}Creating a new Rust library...${NC}"
        cargo new --lib "$project_dir"
        cd "$project_dir"
        
        # Create an example
        mkdir -p examples
        cat > examples/example.rs << 'EOF'
use my_library::greeting;

fn main() {
    let message = greeting("World");
    println!("{}", message);
}
EOF
        
        # Update lib.rs
        cat > src/lib.rs << 'EOF'
//! A simple Rust library.

/// Returns a greeting for the given name.
///
/// # Examples
///
/// ```
/// let message = my_library::greeting("World");
/// assert_eq!(message, "Hello, World!");
/// ```
pub fn greeting(name: &str) -> String {
    format!("Hello, {}!", name)
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_greeting() {
        let result = greeting("Rust");
        assert_eq!(result, "Hello, Rust!");
    }
}
EOF
        
        # Update Cargo.toml
        current_content=$(cat Cargo.toml)
        cat > Cargo.toml << EOF
[package]
name = "$project_name"
version = "0.1.0"
edition = "2021"
description = "A Rust library"
authors = ["Your Name <your.email@example.com>"]
readme = "README.md"
license = "MIT"

[dependencies]

[dev-dependencies]
EOF
        ;;
        
      3)
        # Web application (with Rocket)
        echo -e "${GREEN}Creating a new Rust web application with Rocket...${NC}"
        cargo new "$project_dir"
        cd "$project_dir"
        
        # Add Rocket dependency
        cat >> Cargo.toml << 'EOF'

[dependencies]
rocket = "0.5.0-rc.2"
rocket_dyn_templates = { version = "0.1.0-rc.2", features = ["handlebars"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

EOF
        
        # Create project structure
        mkdir -p src/{routes,models} templates static/{css,js}
        
        # Create main.rs
        cat > src/main.rs << 'EOF'
#[macro_use] 
extern crate rocket;

mod routes;
mod models;

use rocket_dyn_templates::{Template, context};
use rocket::fs::{FileServer, relative};

#[get("/")]
fn index() -> Template {
    Template::render("index", context! {
        title: "Rocket Web App",
        message: "Welcome to your Rocket web application!",
    })
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .mount("/", routes![index, routes::api::hello])
        .mount("/static", FileServer::from(relative!("static")))
        .attach(Template::fairing())
}
EOF
        
        # Create routes module
        mkdir -p src/routes/api
        
        cat > src/routes/mod.rs << 'EOF'
pub mod api;
EOF
        
        cat > src/routes/api.rs << 'EOF'
use rocket::serde::json::{Json, Value, json};
use crate::models::message::Message;

#[get("/hello/<name>")]
pub fn hello(name: &str) -> Json<Value> {
    Json(json!({
        "status": "success",
        "message": format!("Hello, {}!", name)
    }))
}
EOF
        
        # Create models module
        mkdir -p src/models
        
        cat > src/models/mod.rs << 'EOF'
pub mod message;
EOF
        
        cat > src/models/message.rs << 'EOF'
use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Message {
    pub content: String,
}
EOF
        
        # Create templates
        cat > templates/index.html.hbs << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ title }}</title>
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
    <div class="container">
        <h1>{{ title }}</h1>
        <p>{{ message }}</p>
        
        <div class="card">
            <h2>API Example</h2>
            <p>Try the API: <code>/hello/&lt;name&gt;</code></p>
            <div id="result"></div>
            <button id="testApi">Test API</button>
        </div>
    </div>
    
    <script src="/static/js/main.js"></script>
</body>
</html>
EOF
        
        # Create static files
        cat > static/css/style.css << 'EOF'
body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    margin: 0;
    padding: 20px;
    color: #333;
    background-color: #f5f5f5;
}

.container {
    max-width: 800px;
    margin: 0 auto;
    background-color: white;
    padding: 20px;
    border-radius: 5px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

h1 {
    color: #333;
}

.card {
    background-color: #f9f9f9;
    border: 1px solid #ddd;
    border-radius: 4px;
    padding: 15px;
    margin-top: 20px;
}

code {
    background-color: #eee;
    padding: 2px 4px;
    border-radius: 3px;
}

button {
    background-color: #4285f4;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    cursor: pointer;
    margin-top: 10px;
}

button:hover {
    background-color: #3b78e7;
}

#result {
    margin-top: 10px;
    min-height: 20px;
}
EOF
        
        cat > static/js/main.js << 'EOF'
document.addEventListener('DOMContentLoaded', function() {
    const testApiButton = document.getElementById('testApi');
    const resultDiv = document.getElementById('result');
    
    testApiButton.addEventListener('click', function() {
        resultDiv.innerHTML = 'Loading...';
        
        fetch('/hello/World')
            .then(response => response.json())
            .then(data => {
                resultDiv.innerHTML = `<pre>${JSON.stringify(data, null, 2)}</pre>`;
            })
            .catch(error => {
                resultDiv.innerHTML = `Error: ${error.message}`;
            });
    });
});
EOF
        ;;
        
      4)
        # Command line tool (with clap)
        echo -e "${GREEN}Creating a new Rust command line tool with clap...${NC}"
        cargo new "$project_dir"
        cd "$project_dir"
        
        # Add clap dependency
        cat >> Cargo.toml << 'EOF'

[dependencies]
clap = { version = "3.0", features = ["derive"] }
anyhow = "1.0"
log = "0.4"
env_logger = "0.9"

EOF
        
        # Create main.rs with clap
        cat > src/main.rs << 'EOF'
use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use log::{debug, info, warn};

/// A simple CLI application
#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    /// Optional name to operate on
    #[clap(short, long, default_value = "World")]
    name: String,

    /// Sets the verbosity level
    #[clap(short, long, parse(from_occurrences))]
    verbose: usize,

    /// Subcommand to run
    #[clap(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Prints a greeting
    Greet {
        /// Name to greet
        name: Option<String>,
    },
    
    /// Does a calculation
    Calculate {
        /// First number
        #[clap(short, long)]
        x: i32,
        
        /// Second number
        #[clap(short, long)]
        y: i32,
        
        /// Operation to perform
        #[clap(short, long, default_value = "add")]
        operation: String,
    },
}

fn main() -> Result<()> {
    let args = Args::parse();
    
    // Set up logging
    let log_level = match args.verbose {
        0 => log::LevelFilter::Info,
        1 => log::LevelFilter::Debug,
        _ => log::LevelFilter::Trace,
    };
    
    env_logger::builder()
        .filter_level(log_level)
        .init();
    
    debug!("Starting application with args: {:?}", args);
    
    match args.command {
        Some(Commands::Greet { name }) => {
            let name = name.unwrap_or(args.name);
            greet(&name)?;
        }
        Some(Commands::Calculate { x, y, operation }) => {
            calculate(x, y, &operation)?;
        }
        None => {
            greet(&args.name)?;
        }
    }
    
    Ok(())
}

fn greet(name: &str) -> Result<()> {
    debug!("Greeting {}", name);
    println!("Hello, {}!", name);
    Ok(())
}

fn calculate(x: i32, y: i32, operation: &str) -> Result<()> {
    debug!("Calculating {} {} {}", x, operation, y);
    
    let result = match operation {
        "add" => x + y,
        "subtract" => x - y,
        "multiply" => x * y,
        "divide" => {
            if y == 0 {
                warn!("Division by zero attempted");
                return Err(anyhow::anyhow!("Cannot divide by zero"));
            }
            x / y
        },
        _ => {
            return Err(anyhow::anyhow!("Unknown operation: {}", operation)
                .context("Valid operations are: add, subtract, multiply, divide"));
        }
    };
    
    println!("Result: {}", result);
    Ok(())
}
EOF
        ;;
        
      *)
        # Binary (application)
        echo -e "${GREEN}Creating a new Rust binary application...${NC}"
        cargo new "$project_dir"
        cd "$project_dir"
        ;;
    esac
    
    # Update Cargo.toml with common dependencies
    if [ "$project_type" != "2" ]; then
      # For non-library projects
      cat >> Cargo.toml << 'EOF'

[dependencies]
anyhow = "1.0"
log = "0.4"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

EOF
    fi
    
    # Create README
    cat > README.md << EOF
# $project_name

A Rust project.

## Setup

1. Make sure you have Rust installed:
   \`\`\`
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   \`\`\`

2. Clone this repository:
   \`\`\`
   git clone <repository-url>
   cd $project_name
   \`\`\`

3. Build the project:
   \`\`\`
   cargo build
   \`\`\`

4. Run the project:
   \`\`\`
   cargo run
   \`\`\`

## Usage

[Provide usage instructions here]
EOF
    
    # Initialize git repository
    echo -e "\n${CYAN}Initialize Git repository? (y/n):${NC}"
    read -p "> " init_git
    if [[ $init_git =~ ^[Yy]$ ]]; then
      git init
      git add .
      git commit -m "Initial commit"
    fi
    
    echo -e "\n${GREEN}✅ Project initialized at $project_dir${NC}"
    
    if [ "$project_type" == "3" ]; then
      echo -e "\nRun the following commands to start your Rocket web app:"
      echo -e "${CYAN}cd $project_dir${NC}"
      echo -e "${CYAN}cargo run${NC}"
      echo -e "\nThen visit: http://localhost:8000"
    elif [ "$project_type" == "4" ]; then
      echo -e "\nRun the following commands to see CLI help:"
      echo -e "${CYAN}cd $project_dir${NC}"
      echo -e "${CYAN}cargo run -- --help${NC}"
    elif [ "$project_type" == "2" ]; then
      echo -e "\nRun the following commands to test your library:"
      echo -e "${CYAN}cd $project_dir${NC}"
      echo -e "${CYAN}cargo test${NC}"
      echo -e "\nAnd to run the example:"
      echo -e "${CYAN}cargo run --example example${NC}"
    else
      echo -e "\nRun the following commands to build and run your project:"
      echo -e "${CYAN}cd $project_dir${NC}"
      echo -e "${CYAN}cargo run${NC}"
    fi
  fi
  
  echo -e "\n${GREEN}✅ Rust environment setup complete!${NC}"
  rustc --version
  cargo --version
}

# Print header
print_header "Development Environment Setup"
echo -e "This script will help you set up development environments for various programming languages."
echo -e "Projects will be created in ${PROJECTS_DIR}"
echo ""

# Check if a language was specified
if [ -z "$1" ]; then
  echo -e "${CYAN}Usage:${NC} $0 <language> [version]"
  echo ""
  echo -e "${CYAN}Available languages:${NC}"
  echo "  node       - Set up Node.js environment"
  echo "  python     - Set up Python environment"
  echo "  go         - Set up Go environment"
  echo "  rust       - Set up Rust environment"
  echo ""
  echo -e "${CYAN}Examples:${NC}"
  echo "  $0 node lts    - Set up Node.js LTS version"
  echo "  $0 python 3    - Set up Python 3"
  exit 1
fi

# Main
case "$1" in
  node|nodejs)
    setup_node "$2"
    ;;
  python|py)
    setup_python "$2"
    ;;
  go|golang)
    setup_go
    ;;
  rust)
    setup_rust
    ;;
  *)
    echo -e "${RED}Unknown language: $1${NC}"
    echo -e "${CYAN}Available languages:${NC} node, python, go, rust"
    exit 1
    ;;
esac