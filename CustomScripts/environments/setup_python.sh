# For digdag-python:3.7
pip install -r requirements.txt -c constraints.txt

# For digdag-anaconda3:2019.03 with default environment, run
conda env update -f environment.yml
# If you want to avoid updating environment name, use -n option like
conda env create -n my-env -f environment.yml
# For Windows users, run
conda env create -n my-env -f environment_windows.yml