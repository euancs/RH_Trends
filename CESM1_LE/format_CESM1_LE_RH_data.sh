#!bin/bash

# This function takes the raw RH data and calculates the zonal, tropical, and East Pacific means of annual and seasonal data for each CESM1 LE ensemble member

calc_RH_vals() {

    # First define a file name which depends on what the ensemble number is ($1). Details of the ensemble member and branch years here: https://www.cesm.ucar.edu/community-projects/lens/instructions
    
    if [ $1 -eq 1 ]
    then
        file_name=b.e11.B20TRC5CNBDRD.f09_g16.00"$1".cam.h0.RELHUM.
        ncra -O --mro -d time,"1920-02-01",,1,1 "$file_name"185001-200512.nc "$file_name"192001-200512.nc
    elif [ $1 -lt 10 ]
    then
        file_name=b.e11.B20TRC5CNBDRD.f09_g16.00"$1".cam.h0.RELHUM.
    elif [ $1 -lt 100 ]
    then
        file_name=b.e11.B20TRC5CNBDRD.f09_g16.0"$1".cam.h0.RELHUM.
    else 
        file_name=b.e11.B20TRC5CNBDRD.f09_g16."$1".cam.h0.RELHUM.
    fi

    # Subeset the file into 5-level chucks by slabbing to ensure it can run without failing
    for level_subset in {0..5}
    do
    
        ncks -d lev,$(($level_subset*5)),$(($level_subset*5+4)) "$file_name"192001-200512.nc "$file_name"levelsubset"$level_subset".nc

        # Calculate the zonal, tropical and East Pacific means
        #Zonal
        ncwa -a lon "$file_name"levelsubset"$level_subset".nc "$file_name"192001-200512_level"$level_subset"_zonal_mean.nc

        #Tropics
        ncwa -w gw -a lat,lon -d lat,-30.,30. -d lon,0.,360. "$file_name"levelsubset"$level_subset".nc "$file_name"192001-200512_level"$level_subset"_tropical_mean.nc

        #East Pacific
        ncwa -w gw -a lat,lon -d lat,-25.,5. -d lon,220.,280. "$file_name"levelsubset"$level_subset".nc "$file_name"192001-200512_level"$level_subset"_EP_mean.nc

        # Delete original subsetted files
        rm "$file_name"levelsubset"$level_subset".nc
    
    done
    
    # Delete original files
    #rm "$file_name"192001-200512.nc

    for level in {0..5}
    do

        # Now calculate the zonal, tropical and East Pacific annual means
        ncra -O --mro -d time,,,12,12 "$file_name"192001-200512_level"$level"_zonal_mean.nc "$file_name"1920-2005_level"$level"_zonal_mean.nc
        ncra -O --mro -d time,,,12,12 "$file_name"192001-200512_level"$level"_tropical_mean.nc "$file_name"1920-2005_level"$level"_tropical_mean.nc
        ncra -O --mro -d time,,,12,12 "$file_name"192001-200512_level"$level"_EP_mean.nc "$file_name"1920-2005_level"$level"_EP_mean.nc


        # Now calculate the zonal, tropical and East Pacific seasonal means. 
        # Zonal
        ncra -O --mro -d time,"1921-01-01","2005-03-01",12,3 "$file_name"192001-200512_level"$level"_zonal_mean.nc "$file_name"1920-2005_level"$level"_DJF_zonal_mean.nc
        ncra -O --mro -d time,"1920-04-01",,12,3 "$file_name"192001-200512_level"$level"_zonal_mean.nc "$file_name"1920-2005_level"$level"_MAM_zonal_mean.nc
        ncra -O --mro -d time,"1920-07-01",,12,3 "$file_name"192001-200512_level"$level"_zonal_mean.nc "$file_name"1920-2005_level"$level"_JJA_zonal_mean.nc
        ncra -O --mro -d time,"1920-10-01",,12,3 "$file_name"192001-200512_level"$level"_zonal_mean.nc "$file_name"1920-2005_level"$level"_SON_zonal_mean.nc

        # Tropical
        ncra -O --mro -d time,"1921-01-01","2005-03-01",12,3 "$file_name"192001-200512_level"$level"_tropical_mean.nc "$file_name"1920-2005_level"$level"_DJF_tropical_mean.nc
        ncra -O --mro -d time,"1920-04-01",,12,3 "$file_name"192001-200512_level"$level"_tropical_mean.nc "$file_name"1920-2005_level"$level"_MAM_tropical_mean.nc
        ncra -O --mro -d time,"1920-07-01",,12,3 "$file_name"192001-200512_level"$level"_tropical_mean.nc "$file_name"1920-2005_level"$level"_JJA_tropical_mean.nc
        ncra -O --mro -d time,"1920-10-01",,12,3 "$file_name"192001-200512_level"$level"_tropical_mean.nc "$file_name"1920-2005_level"$level"_SON_tropical_mean.nc

        # East Pacific
        ncra -O --mro -d time,"1921-01-01","2005-03-01",12,3 "$file_name"192001-200512_level"$level"_EP_mean.nc "$file_name"1920-2005_level"$level"_DJF_EP_mean.nc
        ncra -O --mro -d time,"1920-04-01",,12,3 "$file_name"192001-200512_level"$level"_EP_mean.nc "$file_name"1920-2005_level"$level"_MAM_EP_mean.nc
        ncra -O --mro -d time,"1920-07-01",,12,3 "$file_name"192001-200512_level"$level"_EP_mean.nc "$file_name"1920-2005_level"$level"_JJA_EP_mean.nc
        ncra -O --mro -d time,"1920-10-01",,12,3 "$file_name"192001-200512_level"$level"_EP_mean.nc "$file_name"1920-2005_level"$level"_SON_EP_mean.nc
        
    done
    
    # Remove files to be left with only annual and seasonal mean files
    rm "$file_name"192001-200512*_zonal_mean.nc
    rm "$file_name"192001-200512*_tropical_mean.nc
    rm "$file_name"192001-200512*_EP_mean.nc
}

# Run this function for all 42 ensembles

# First 35 ensembles
for ensemble in {1..35}
do
    calc_RH_vals $ensemble
done


# Last 7 ensembles
for ensemble in {101..107}
do
    calc_RH_vals $ensemble
done

