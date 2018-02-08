"""Script for downloading images from the HiRISE PDS.
Authors: Michael Pellet and Nemanja Stojoski
26.12.2017
"""
import requests
import shutil
from bs4 import BeautifulSoup
import os

#list of keywords that are extracted from the .LBL files
keywords = ['MAP_PROJECTION_ROTATION', 'MAP_RESOLUTION', 'MAP_SCALE',
	    'MAXIMUM_LATITUDE', 'MINIMUM_LATITUDE',
	    'LINE_PROJECTION_OFFSET', 'SAMPLE_PROJECTION_OFFSET',
	    'EASTERNMOST_LONGITUDE', 'WESTERNMOST_LONGITUDE']

def download_image_with_lbl(image_url, image_name):
    """A function for downloading a single image.
    This function downloads the image with the image_name
    from the specified image_url."""
    global download_count
    #increase the download count
    download_count += 1
    #get image
    r_img = requests.get(image_url + image_name, stream = True)
    url_list = image_url.split('/')
    label_list = url_list[:4] + url_list[5:]
    label_url = ('/').join(label_list)
    label_name = image_name.split('.')[0] + '.LBL'
    image_path = 'D:/IPEO/Project/images/'
    file_content = []
    #200 - HTTP status code for successful request
    if r_img.status_code == 200:
        #create folders to the image if they don't exist
        if not os.path.exists(image_path):
            os.makedirs(image_path)
        print('Downloading ' + str(download_count) + ': '
        	+ image_url + image_name)
        #write image into file
        with open(image_path + '/' + image_name, 'wb') as f:
            for chunk in r_img:
                f.write(chunk)
        #get label
        r_url = requests.get(label_url + label_name)
        if r_url.status_code == 200:
            print(label_url + label_name)
            for line in r_url.text.split('\n'):
                    pair = line.split('=')
                    #extract all keyword values
                    if pair[0].strip() in keywords:
                        #add them to a list
                        file_content.append(pair[1].strip().split(' ')[0])
            with open(image_path + '/' + label_name, "w") as label_file:
                #print list joined with ', ' to file
                print(f"{', '.join(file_content)}", file = label_file)

def download_all_images(base_url, ext):
    """A function for downloading multiple images.
    This function downloads all images with the extension ext
    from the specified base_url."""
    r = requests.get(base_url)
    soup = BeautifulSoup(r.text, 'html.parser')
    #iterate through all orbits
    for link in soup.findAll('a'):
            if link.string != '../':
                orbit_url = base_url + link.string
                r = requests.get(orbit_url)
                soup = BeautifulSoup(r.text, 'html.parser')
                #iterate through all images in an orbit
                for link in soup.findAll('a'):
                    if link.string != '../':
                        img_url = orbit_url + link.string
                        image_name = link.string[:-1] + ext
                        download_image_with_lbl(img_url, image_name)

#specify the base_url from which the images are downloaded
base_url = 'https://hirise-pds.lpl.arizona.edu/PDS/EXTRAS/RDR/ESP/'
#specify the image extension
ext = '_RED.NOMAP.browse.jpg'
download_count = 0
#start download
download_all_images(base_url, ext)
