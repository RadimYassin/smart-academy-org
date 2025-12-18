# How to Fix the Dependency Issue

## Problem
The application fails to start with error:
```
TypeError: ForwardRef._evaluate() missing 1 required keyword-only argument: 'recursive_guard'
```

This is caused by incompatibility between Pydantic v2 and old LangChain versions.

## Solution Steps

### Option 1: Quick Fix (Recommended)

1. **Close all Python processes** and deactivate the virtual environment:
   ```powershell
   deactivate
   ```

2. **Delete the virtual environment folder**:
   ```powershell
   Remove-Item -Recurse -Force .\venv -ErrorAction SilentlyContinue
   ```

3. **Create a fresh virtual environment**:
   ```powershell
   python -m venv venv
   ```

4. **Activate it**:
   ```powershell
   .\venv\Scripts\activate
   ```

5. **Install using the fixed requirements**:
   ```powershell
   pip install -r requirements-fixed.txt
   ```

6. **Copy the fixed requirements over the original** (optional):
   ```powershell
   copy requirements-fixed.txt requirements.txt
   ```

7. **Run the application**:
   ```powershell
   python main.py
   ```

### Option 2: Manual Fix

If Option 1 doesn't work, manually upgrade these packages:

```powershell
pip uninstall langchain langchain-community langchain-openai langchain-core -y
pip install langchain==0.2.11 langchain-community==0.2.10 langchain-openai==0.1.17 langchain-core==0.2.23
pip install sentence-transformers==2.5.1
pip install "numpy<2.0.0"
pip install tiktoken
```

## What Changed?

Updated packages:
- `langchain`: 0.1.6 → 0.2.11
- `langchain-community`: 0.0.20 → 0.2.10
- `langchain-openai`: 0.0.5 → 0.1.17
- `langchain-core`: 0.1.23 → 0.2.23
- `sentence-transformers`: 2.3.1 → 2.5.1

Added packages:
- `tiktoken` (required for newer LangChain)
- `numpy<2.0.0` (compatibility constraint)

These versions are fully compatible with Pydantic v2 (2.5.3).
