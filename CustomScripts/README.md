# Code snippet for Custom Scripts course

There are two directories for code snippets and setting up environment.

## codes

pandas and access_summary are used in training course.
exercise is for more advanced hands-on examples.

- pandas
  - Example workflow for TD data reading/writing
- access_summary
  - Example of hands-on
- exercise
  - Workflows for exercises

## environments

### macOS

For setting up macOS environment from scratch, run:

```sh
./environments/setup_python_mac.sh
```

Note that, to install Python, root password is required.

After running the script, you can activate the virtual environment as:

```sh
source ~/training/bin/activate
```

After activation, check the installed packages with:

```sh
pip freeze
```

### Windows10

For setting up Windows environment, download Anaconda3-2019.03 from either of the following URLs:

- (64bit) https://repo.anaconda.com/archive/Anaconda3-2019.03-Windows-x86_64.exe
- (32bit) https://repo.anaconda.com/archive/Anaconda3-2019.03-Windows-x86.exe

Open Anaconda Prompt and run:

```cmd
conda env craete -n my-env -f environment_windows.yml
```

Check for installation with running:

```cmd
conda activate my-env
```

and compare installed packages between environment_windows.yml and the output of the following command:

```cmd
conda env export -n my-env
```
