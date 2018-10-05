print "################################################################"
print "-------  Removing bad pixels from image using a MEF mask -------"


# INSTRUCTIONS
# 1) Requisites: place the gireduce-d GMOS images (unmosaiced), the BPM (rename it as "mask.fits") and this script in a directory.
#	For creating a mask you can use the script ggbpm.02.yyyymmmdd.cl
# 2) Build the "images.txt" file with the names of the gireduce-d GMOS images, one per lin (e.g.: ls rgS20*.fits >> images.txt)
# 3) Run the script:
#	 cl < ggbpm.04.yyyymmmdd.cl
# 4) Var and DQ are adding


string *list11
string *list12
crutil
fitsutil

delete grg*
delete cleaned*

ls gS2*.fits
#cat Sci.txt >> images.txt
#cat Arc.txt >> images.txt

list11= 'images.txt'   # List of images to be corrected
while (fscan (list11, s1) != EOF){

        delete phu.fits
        imcopy (s1//"[0]", "g"//s1//"[0]", verbose=yes)

delete ext_sci.txt,ext_var.txt,ext_dq.txt
gemextn (s1, extname="SCI", extversion="1-", outfile="ext_sci.txt", logfile="gemextn.log")
gemextn (s1, extname="VAR", extversion="1-", outfile="ext_var.txt", logfile="gemextn.log")
gemextn (s1, extname="DQ", extversion="1-", outfile="ext_dq.txt", logfile="gemextn.log")
i=1
list12 = 'ext_sci.txt'
while (fscan (list12, s2) != EOF){

        print(i)
        crutil.crfix(s1//"[SCI,"//i//"]", output="cleaned"//i//".fits", crmask="mask.fits["//i//"]")
        print ("extension "//i," cleaned")
        dir ("cleaned"//i//".fits", >>& 'extlist.txt')
        print ""
        imreplace ("cleaned"//i//".fits", 0., upper=0.)
        imcopy ("cleaned"//i//".fits", "g"//s1//"[SCI,"//i//"]")
                i=i+1
        j=i
        print(j)
    }

	print "-------Rebuilding the MEF file------"



	imgets ("g"//s1//"[0]", "obsmode")

	if (imgets.value == "MOS") {

#****For MOS****
#####====Inserting the MDF====####
imgets(s1//"[0]",'GEMCOMB')
print (imgets.value)
if (!access(imgets.value) || imgets.value == '0') {
	print("not gemcombined", >& 'comb.status')
	fxinsert (s1//"["//i//"]", "g"//s1//"["//i-1//"][MDF,1]","0", verbose=no)
} else if (imgets.value == '1') { 
	print("gemcombined", >& 'comb.status')
	fxinsert (s1//"["//1//"]", "g"//s1//"["//i-1//"][MDF,1]","0", verbose=no)
}
####=========================####

	} else if (imgets.value == "LONGSLIT" || imgets.value == "IFU") {

#****For LS****
#####====Inserting the MDF====####
	fxinsert (s1//"["//i//"]", "g"//s1//"["//i-1//"][MDF,1]","0", verbose=no)
####=========================####

} else if (imgets.value == "IMAGE") {

print ("Imaging mode")

}

    list12 = 'ext_var.txt'
    type ext_var.txt
    while (fscan (list12, s2) != EOF){
          print(i)
          j=i
          k=j+1
          print(j,k)
    imcopy (s2, "g"//s2)
}
                          
    list12 = 'ext_dq.txt'
    type ext_dq.txt
    while (fscan (list12, s2) != EOF){
          print(i)
          j=i
          k=j+1
          print(j,k)
    imcopy (s2, "g"//s2)
}

    gemextn ("g"//s1)
	imdelete cleaned*.fits
	

}






print "################################################################"
print "                    ---------Done---------         "

