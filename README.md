# Repository Structure Quick Rundown
This repository mimics a real-world setup that you might find when working on research projects to provides an example on how to setup and execute your Maniskill3 workload on a cluster.  

## `cluster` Folder
This folder contains scripts that can be used to send jobs on the cluster using SLURM.  
The DRAC script shows a template for sending jobs on [DRAC clusters](https://alliancecan.ca/en/services/advanced-research-computing/national-services/clusters) while the MILA script shows an example for the [MILA cluster](https://docs.mila.quebec/).   

## `envs/maniskill3` Folder  
This folder contains the conda environment definition, note that using conda is not mandatory, there are other alternatives but here we're using conda for demo purposes.  
The conda environment is fairly simple defining which python version to use and what maniskill3 version to install.  

## `scripts` Folder  
This folder contains the script that will be executed inside the container, usually these are training or evaluation scripts for instance. These scripts are users of your code living inside the `src/` folder.  

## `singularity` Folder  
This folder contains the files specific to Singularity such as the [Singularity Recipe](https://docs.sylabs.io/guides/2.6/user-guide/container_recipes.html).  
`build_image.sh` is a small script that builds the image defined by the `recipe.def` file.  
Note : `recipe.def` is similar to a docker file if you're coming from Docker.    

## `src` Folder  
The `src` directory is where you put any reusable code your project needs.  

For example, you might include:
- A few custom model classes (`nn.Module`)  
- One-off algorithm implementations or training loops  
- Utility functions for data loading, logging, or configs  
- …or really anything else you want to share across scripts  

## `requirements.txt` File
This file contains the library and exact versions that you are using during your research. This file acts as both documentation for others and also allows to install the proper dependencies in the container.

---

# Running Maniskill3 on a Cluster
We can use the same singularity recipe regardless of the cluster but there is important details that must be addressed to make the image work on any cluster.  
Depending on if your cluster compute nodes (the host) has a different OS than your container's OS, you might need to do special setups in your cluster SLURM scripts, you can check the subsections below to learn more about each case.  
Otherwise here is the general flow :  
1. [LOCAL MACHINE] Build the singularity image.  
    ```bash
    cd singularity/
    ./build_image.sh
    ```

2. [LOCAL MACHINE] Upload the singularity image to your cluster.
3. If needed edit the SLURM sbatch scripts under `cluster/`, for the MILA cluster it can work as-is for the demo, for the DRAC clusters you need to replace the tags `<YOUR_SUPERVISOR_ACCOUNT>` (eg: `def-mysupervisor`), `<YOUR_USERNAME>` (eg: `myusername`) and `<PATH_TO_FOLDER_WITH_YOUR_REPOS>` (eg: home folder where you cloned your repos).
4. [CLUSTER] Use sbatch to schedule the job.
    ```bash
    sbatch cluster/mila_cluster_sbatch_script_example.sh
    ```

## Detailed Description of each case and why the two sbatch scripts differ

### Case 1 : Host OS = Container OS

This is the simplest case and is repersented by the MILA cluster in this repo. You might have a cluster whose compute nodes use Ubuntu and our container also uses Ubuntu for instance.  
In this case, there is no special setup needed with regards to the GPU/CUDA/Vulkan libraries/drivers, we can let singularity automatically bind the Host's drivers using the `--nv` flag and it works fine.  
An example of this is shown in `cluster/mila_cluster_sbatch_script_example.sh`.  
We ensure that the modules for singularity/apptainer are loaded as well as cuda then we can run our singularity image and the `--nv` flag will do its work.  
To avoid warnings, we also bind the vulkan json files from the host to the container (see the `--bind` inside the script for `nvidia_icd.json`, `nvidia_layers.json`, `10_nvidia.json`), the exact location on the host might differ per cluster but the principle is the same, we use the host json files and bind them to be in the appropriate location in our container.  
If your cluster does not have these files, you can create them following https://maniskill.readthedocs.io/en/latest/user_guide/getting_started/installation.html#ubuntu and add them to your container at build time.

The script assumes you already read the [MILA doc](https://docs.mila.quebec/Userguide.html), this describes what `$SLURM_TMPDIR` and `$SCRATCH` are for instance. The TLDR is that `$SCRATCH` is where we can store our image and final job data that we want to keep for later retrieval and `$SLURM_TMPDIR` is a temporary folder created and available only during job execution.  
This script assumes you cloned your repository to `$HOME/my_repo` and `/code/` is bound to `$HOME`. It also assumes you named your image `my_image.sif` but this can be changed. It also expects your image to be available on the cluster under `$SCRATCH/containers/my_image.sif` but again this can be changed in the script if needed.  


### Case 2 : Host OS $\neq$ Container OS  

In this case, the host OS might be Rocky Linux and the container OS might be something else (eg: Ubuntu 22.04 as in our case).  
In this case singularity `--nv` flag will not know how to  bind the nvidia drivers/libs properly.  

This is due to how the host OS and container OS structure their libs files.  

#### Host OS Lib Folder Structure
On Rocky Linux, the lib files for nvidia/egl/vulkan are stored under `/usr/lib64/`.  
Example :  
On the host we can run :  
```bash
ls /usr/lib64/libnvidia-*
```
This will return something like this :  
```bash
/usr/lib64/libnvidia-allocator.so.1
/usr/lib64/libnvidia-allocator.so.570.148.08
/usr/lib64/libnvidia-api.so.1
...
/usr/lib64/libnvidia-vksc-core.so.570.148.08
/usr/lib64/libnvidia-wayland-client.so.570.148.08
```
Conversly, the following is also true, if we run :  
```bash
ls /usr/lib64/libnvidia-*
```
We migth get something like :  
```
/usr/lib64/libEGL_mesa.so.0      
/usr/lib64/libEGL_nvidia.so.0
/usr/lib64/libEGL_mesa.so.0.0.0  
/usr/lib64/libEGL_nvidia.so.570.148.08
```
Notice that `/usr/lib64/libEGL_nvidia.so.0` is the same file that is expected by `/usr/share/glvnd/egl_vendor.d/10_nvidia.json`

```bash
[host]$ cat /usr/share/glvnd/egl_vendor.d/10_nvidia.json
{
    "file_format_version" : "1.0.0",
    "ICD" : {
        "library_path" : "libEGL_nvidia.so.0"
    }
}
```
The same is true for other lib files such as `libGLX_nvidia.so.0` which is needed by `/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json`
```bash
[brownz@ng31304 ~]$ cat /usr/share/vulkan/icd.d/nvidia_icd.x86_64.json
{
    "file_format_version" : "1.0.1",
    "ICD": {
        "library_path": "/usr/lib64/libGLX_nvidia.so.0",
        "api_version" : "1.4.303"
    }
}
```
Notice that in the case of `/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json` the `library_path` is absolute in our case (might be different for your cluster), so this is why we need to also bind the file to this exact location when running our container :   
```
--bind /usr/lib64/libGLX_nvidia.so.0:/usr/lib64/libGLX_nvidia.so.0
```

Depending on your host you might have `/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json` or `/usr/share/vulkan/icd.d/nvidia_icd.json` or `/etc/vulkan/icd.d/nvidia_icd.json`.  
If you have `/.../nvidia_icd.x86_64.json` vulkan won't find it.   
To solve this we can bind the host file `/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json` to be `/usr/share/vulkan/icd.d/nvidia_icd.json` in the container so that it is found by Vulkan.  
An alternative would probably be to use `VK_ICD_FILENAMES` environment variable instead but I haven't tested it.     

If your host does not already have the following paths:  
- `/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json` or `/usr/share/vulkan/icd.d/nvidia_icd.json`
- `/usr/share/vulkan/implicit_layer.d/nvidia_layers.json`
- `/usr/share/glvnd/egl_vendor.d/10_nvidia.json`

Then you need to create them in your container following https://maniskill.readthedocs.io/en/latest/user_guide/getting_started/installation.html#ubuntu

#### Container OS Lib Folder Structure

Newer versions of Ubuntu (eg: 22.04 is included) adopted a different folder structure to store lib files, it uses a multiarch spec folder structure to store libraries (see https://unix.stackexchange.com/questions/43190/where-did-usr-lib64-go-and-what-is-usr-lib-x86-64-linux-gnu/43214#43214).  
This means that libs are not stored under `/usr/lib64/` but rather under `/usr/lib/x86_64-linux-gnu/`.  

Therefore in order to properly bind the libs from the host OS to the container, we need to add `--bind` flags that link the host lib files to the container.  
Simply binding the entire `/usr/lib64/` folder is not advised as this most likely will cause  breaking issues since it will also copy other libs than the nvidia/vulkan libs.  
Instead we can take the result from `ls /usr/lib64/{libnvidia-*,libEGL_*,libGLX_*,libvulkan*}` and add a `--bind` for those files only.  
The script `cluster/drac_cluster_sbatch_script_example.sh` does this programmatically by automatically adding the `--bind` for each files on the host returned by `ls /usr/lib64/{libnvidia-*,libEGL_*,libGLX_*,libvulkan*}`. This ensures we don't have to manually add the binds and that no error is made.  

The script also adds an extra bind for `--bind /usr/lib64/libGLX_nvidia.so.0:/usr/lib64/libGLX_nvidia.so.0` since the icd json file uses absolute path in our case, we must make the that the file lives at this exact path in the container.  

The script adds other binds for the vulkan json files:  
```bash
lib_bind_flags+=" --bind /usr/share/vulkan/icd.d/nvidia_icd.x86_64.json:/usr/share/vulkan/icd.d/nvidia_icd.json"
lib_bind_flags+=" --bind /usr/share/vulkan/implicit_layer.d/nvidia_layers.json:/usr/share/vulkan/implicit_layer.d/nvidia_layers.json"
lib_bind_flags+=" --bind /usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json"
```  
Again if these files do not exist on your host then you need to create them manually and copy them inside your container at build time instead of binding the host json files.  

The script also passes the following environment variable at runtime :  
```bash
--env LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH
```
This ensures that the lib files can be found and used.  
Using an environment variable allows us to re-use the same singularity image while accommodating for the different cluster at runtime.  

The script also has comments that summarize these changes.  

Note: You'd need to replace the tags `<YOUR_SUPERVISOR_ACCOUNT>`, `<YOUR_USERNAME>` and `<PATH_TO_FOLDER_WITH_YOUR_REPOS>` in the script with the proper values.  
`<PATH_TO_FOLDER_WITH_YOUR_REPOS>` is assumed to be a folder the contains your repos (eg: home folder).  
