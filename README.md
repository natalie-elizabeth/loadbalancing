# Load Balancing

Load Balancing MySQL servers using HaProxy

## Steps
- Clone this repo
- Go to Google Cloud Platform and sign up for an account and then create a Project. If this is your first time using GCP, there is a search bar at the top
of the page that can be used to take you wherever you want. 
- Create a Service account Key and download it in json format. For purposed of this project, save the file as database_load.json and save it to the root of the project you just cloned.
- Add project-wide metadata to help with configuration. In most of the setup files, you will see metadata mentioned when assigning variable names. You can use this command 
to add project-wide metadata `gcloud compute project-info add-metadata --metadata slave_password=password,slave_username=user`
- If you haven't already, install packer and terraform to your machine.

## Deployment
Run the commands under deploy.sh. For each of ther servers, bake the image first then run `terraform apply` so you can get the internal IP addresses to be used in the Haproxy config file.
Once that is done for the master and slaves, update the cfg file under mysql-cluster with the correct internal IP addresses. AFter that, run the packer build step for HaProxy then terraform.

### Accessing the HAproxy statistics page
To access the stats page, you will need the HaProxy External IP and the port that the stats page has been bound to. In this case: `http://HaProxy_IP:8000`

Sample image:
![haproxy stats](images/haprxy.png?raw=true "haproxy stats")