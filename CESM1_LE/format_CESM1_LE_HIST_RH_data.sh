#!bin/bash

# This function takes the raw RH data and calculates the zonal, tropical, and East Pacific means of annual and seasonal data for each CESM1 LE ensemble member

calc_RH_vals() {

    # First define a file name which depends on what the ensemble number is ($1). Details of the ensemble member and branch years here: https://www.cesm.ucar.edu/community-projects/lens/instructions
    
    if [ $1 -eq 1 ]
    then
        file_name=b.e11.B20TRC5CNBDRD.f09_g16.00"$1".cam.h0.RELHUM.
        years=185001-200512
        years2=1850-2005
    elif [ $1 -lt 10 ]
    then
        file_name=b.e11.B20TRC5CNBDRD.f09_g16.00"$1".cam.h0.RELHUM.
        years=192001-200512
        years2=1920-2005
    elif [ $1 -lt 100 ]
    then
        file_name=b.e11.B20TRC5CNBDRD.f09_g16.0"$1".cam.h0.RELHUM.
        years=192001-200512
        years2=1920-2005
    else 
        file_name=b.e11.B20TRC5CNBDRD.f09_g16."$1".cam.h0.RELHUM.
        years=192001-200512
        years2=1920-2005
    fi

    # Subeset the file into 2-year chucks by slabbing to ensure it can run without failing
    for year_subset in {0..78}
    do

    #Zonal
    ncks -d time,$(($year_subset*24)),$(($year_subset*24+23)),1 "$file_name""$years".nc "$file_name"yearsubset"$year_subset".nc

    # Calculate the zonal, tropical and East Pacific means
    #Zonal
    ncwa -a lon "$file_name"yearsubset"$year_subset".nc "$file_name"yearsubset"$year_subset"_zonal_mean.nc

    #Tropics
    ncwa -w gw -a lat,lon -d lat,-30.,30. -d lon,0.,360. "$file_name"yearsubset"$year_subset".nc "$file_name"yearsubset"$year_subset"_tropical_mean.nc

    #East Pacific
    ncwa -w gw -a lat,lon -d lat,-25.,5. -d lon,220.,280. "$file_name"yearsubset"$year_subset".nc "$file_name"yearsubset"$year_subset"_EP_mean.nc

    # Delete subsetted files
    rm "$file_name"yearsubset"$year_subset".nc
    
    done
    
    # Delete original files
    rm "$file_name""$years".nc
    

    # Concatenate subsetted files together 
    cdo cat "$file_name"*_zonal_mean.nc "$file_name""$years"_zonal_mean.nc
    cdo cat "$file_name"*_tropical_mean.nc "$file_name""$years"_tropical_mean.nc
    cdo cat "$file_name"*_EP_mean.nc "$file_name""$years"_EP_mean.nc
    
    # Remove the subsetted files
    rm "$file_name"yearsubset*_zonal_mean.nc
    rm "$file_name"yearsubset*_tropical_mean.nc
    rm "$file_name"yearsubset*_EP_mean.nc

    # Now calculate the zonal, tropical and East Pacific annual means
    ncra -O --mro -d time,,,12,12 "$file_name""$years"_zonal_mean.nc "$file_name""$years2"_zonal_mean.nc
    ncra -O --mro -d time,,,12,12 "$file_name""$years"_tropical_mean.nc "$file_name""$years2"_tropical_mean.nc
    ncra -O --mro -d time,,,12,12 "$file_name""$years"_EP_mean.nc "$file_name""$years2"_EP_mean.nc

    # Now calculate the zonal, tropical and East Pacific seasonal means. The years are different for the first ensemble
    if [ $1 -eq 1 ]
    then
        # Zonal
        ncra -O --mro -d time,"1851-01-01",,12,3 "$file_name""$years"_zonal_mean.nc "$file_name""$years2"_DJF_zonal_mean.nc
        ncra -O --mro -d time,"1850-04-01",,12,3 "$file_name""$years"_zonal_mean.nc "$file_name""$years2"_MAM_zonal_mean.nc
        ncra -O --mro -d time,"1850-07-01",,12,3 "$file_name""$years"_zonal_mean.nc "$file_name""$years2"_JJA_zonal_mean.nc
        ncra -O --mro -d time,"1850-10-01",,12,3 "$file_name""$years"_zonal_mean.nc "$file_name""$years2"_SON_zonal_mean.nc

        # Tropical
        ncra -O --mro -d time,"1851-01-01",,12,3 "$file_name""$years"_tropical_mean.nc "$file_name""$years2"_DJF_tropical_mean.nc
        ncra -O --mro -d time,"1850-04-01",,12,3 "$file_name""$years"_tropical_mean.nc "$file_name""$years2"_MAM_tropical_mean.nc
        ncra -O --mro -d time,"1850-07-01",,12,3 "$file_name""$years"_tropical_mean.nc "$file_name""$years2"_JJA_tropical_mean.nc
        ncra -O --mro -d time,"1850-10-01",,12,3 "$file_name""$years"_tropical_mean.nc "$file_name""$years2"_SON_tropical_mean.nc

        # East Pacific
        ncra -O --mro -d time,"1851-01-01",,12,3 "$file_name""$years"_EP_mean.nc "$file_name""$years2"_DJF_EP_mean.nc
        ncra -O --mro -d time,"1850-04-01",,12,3 "$file_name""$years"_EP_mean.nc "$file_name""$years2"_MAM_EP_mean.nc
        ncra -O --mro -d time,"1850-07-01",,12,3 "$file_name""$years"_EP_mean.nc "$file_name""$years2"_JJA_EP_mean.nc
        ncra -O --mro -d time,"1850-10-01",,12,3 "$file_name""$years"_EP_mean.nc "$file_name""$years2"_SON_EP_mean.nc
    
    else
        # Zonal
        ncra -O --mro -d time,"1921-01-01",,12,3 "$file_name""$years"_zonal_mean.nc "$file_name""$years2"_DJF_zonal_mean.nc
        ncra -O --mro -d time,"1920-04-01",,12,3 "$file_name""$years"_zonal_mean.nc "$file_name""$years2"_MAM_zonal_mean.nc
        ncra -O --mro -d time,"1920-07-01",,12,3 "$file_name""$years"_zonal_mean.nc "$file_name""$years2"_JJA_zonal_mean.nc
        ncra -O --mro -d time,"1920-10-01",,12,3 "$file_name""$years"_zonal_mean.nc "$file_name""$years2"_SON_zonal_mean.nc

        # Tropical
        ncra -O --mro -d time,"1921-01-01",,12,3 "$file_name""$years"_tropical_mean.nc "$file_name""$years2"_DJF_tropical_mean.nc
        ncra -O --mro -d time,"1920-04-01",,12,3 "$file_name""$years"_tropical_mean.nc "$file_name""$years2"_MAM_tropical_mean.nc
        ncra -O --mro -d time,"1920-07-01",,12,3 "$file_name""$years"_tropical_mean.nc "$file_name""$years2"_JJA_tropical_mean.nc
        ncra -O --mro -d time,"1920-10-01",,12,3 "$file_name""$years"_tropical_mean.nc "$file_name""$years2"_SON_tropical_mean.nc

        # East Pacific
        ncra -O --mro -d time,"1921-01-01",,12,3 "$file_name""$years"_EP_mean.nc "$file_name""$years2"_DJF_EP_mean.nc
        ncra -O --mro -d time,"1920-04-01",,12,3 "$file_name""$years"_EP_mean.nc "$file_name""$years2"_MAM_EP_mean.nc
        ncra -O --mro -d time,"1920-07-01",,12,3 "$file_name""$years"_EP_mean.nc "$file_name""$years2"_JJA_EP_mean.nc
        ncra -O --mro -d time,"1920-10-01",,12,3 "$file_name""$years"_EP_mean.nc "$file_name""$years2"_SON_EP_mean.nc
    
    fi
      
    # Remove files to be left with only annual and seasonal mean files
    rm "$file_name""$years"_zonal_mean.nc
    rm "$file_name""$years"_tropical_mean.nc
    rm "$file_name""$years"_EP_mean.nc
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

