print "########################################################################"
print "---------------  Creating a bad column mask from images  ---------------"

# GG, 2018feb07
#
# This short script creates a bad colum pixels mask from the raw science data. Works for all modes (imaging and spectroscopy)
# The output is a MEF fits mask named "mask.fits"
#
# Usage:
# 1) Build the "list.txt" file with the names of the raw GMOS images, one per line (e.g.: ls S20*.fits >> list.txt) 
# 2) The script will trim and median combine the images. IF you have only one image, comment out the 'gemcombine' line and uncomment the line immediately below. Note however that if you only have one frame in IMAGING mode AND bright sources, these may be masked as well.
# 3)  Adjustable parameters are the UPPER limit for column detection (the bad columns are usually above 30k counts) and the width of the kernel for the widening function (1-2 pixels). These can be modified inside the code below



 
string *list1
delete extlist.txt,extlist_mask.txt,extlist_res.txt
delete mask.fits,median.fits

list1 = 'list.txt'
gireduce ("@list.txt", fl_bias-, fl_flat-, fl_trim+, fl_over-, outpref="y")

gemcombine ("ygS201*", "median", combine='median')   # use this if you have more than one image
#copy ygS20*.fits median.fits			# use this if you have only one image

imcopy median[0] mask[0]



i=1
for (i=1; i<=12; i+=1) {
	print(i)
	imreplace ("median[SCI,"//i//"]", value=0., lower = INDEF, upper=30000.)  # set to zero anything below UPPER. Default is 30000
	imreplace ("median[SCI,"//i//"]", value=1., lower = 1., upper=INDEF)      # set to 1. all the rest

	gauss ("median[SCI,"//i//"]" , "mask[SCI,"//i//"]" , sigma=6.)   # the sigma value can be changed if necessary. Will depend on the actual width of the column

	hedit("mask[SCI,"//i//"]",fields="OBJECT", value="bad_column_mask", verify=no)   #  update OBJECT keyword

	imreplace ("mask[SCI,"//i//"]", value=1.,  lower=0.1)
	imreplace ("mask[SCI,"//i//"]", value=0.,  upper=0.1)

};


hedit("mask[0]",fields="OBJECT",value="bad_column_mask",verify=no)

delete y*.fits,gS0*.fits


