#!bin/bash

# This function takes the raw RH data and calculates the zonal, tropical, and East Pacific means of annual and seasonal data for each CESM2 LE ensemble member. This works for the SSP370 data

calc_RH_vals() {

    # First define a file name which depends on whether the model is CMIP or smoothed CMIP6 BMB, when the branch year is (AMOC vs drift), what the ensemble number is ($1) and what branch year the model is ($2). Details of the ensemble member and branch years here: https://www.cesm.ucar.edu/community-projects/lens2
    
    # Outer loop: choose whether the ensemble is part of the drift or AMOC branch
    if [ "$branch" = "drift" ]
    then
    
        # Middle loop: choose whether the ensemble is CMIP6 or smoothed CMIP6 BMB 
        if [ "$model" = "cmip6" ]
        then
    
            # Inner loop: choose whether ensemble name name one or two leading zeros
            if [ $1 -eq 10 ]
            then
                file_name=b.e21.BSSP370"$model".f09_g17.LE2-"$((($1-1)*2+100))"1.0"$1".cam.h0.RELHUM.
            else
                file_name=b.e21.BSSP370"$model".f09_g17.LE2-"$((($1-1)*2+100))"1.00"$1".cam.h0.RELHUM.                
            fi
                
        elif [ "$model" = "smbb" ]
        then
        
            if [ $1 -eq 10 ]
            then
                file_name=b.e21.BSSP370"$model".f09_g17.LE2-"$((($1-1)*2+101))"1.0"$1".cam.h0.RELHUM.
            else
                file_name=b.e21.BSSP370"$model".f09_g17.LE2-"$((($1-1)*2+101))"1.00"$1".cam.h0.RELHUM.
            fi

        fi
    
    elif [ "$branch" = "amoc" ]
    then
        
        if [ "$model" = "cmip6" ]
        then
    
            if [ $1 -eq 10 ]
            then
                file_name=b.e21.BSSP370"$model".f09_g17.LE2-"$2"1.0"$1".cam.h0.RELHUM.
            else
                file_name=b.e21.BSSP370"$model".f09_g17.LE2-"$2"1.00"$1".cam.h0.RELHUM.               
            fi
                
        elif [ "$model" = "smbb" ]
        then
        
            file_name=b.e21.BSSP370"$model".f09_g17.LE2-"$2"1.0"$1".cam.h0.RELHUM.

        fi
        
    fi


    # Now calculate the zonal, tropical and East Pacific RH means for each 10 year period
    for year in {2015..2085..10}
    do

    #Zonal
    ncwa -a lon "$file_name""$year"01-"$(($year+9))"12.nc "$file_name""$year"01-"$(($year+9))"12_zonal_mean.nc

    #Tropics
    ncwa -w gw -a lat,lon -d lat,-30.,30. -d lon,0.,360. "$file_name""$year"01-"$(($year+9))"12.nc "$file_name""$year"01-"$(($year+9))"12_tropical_mean.nc

    #East Pacific
    ncwa -w gw -a lat,lon -d lat,-25.,5. -d lon,220.,280. "$file_name""$year"01-"$(($year+9))"12.nc "$file_name""$year"01-"$(($year+9))"12_EP_mean.nc

    # Delete original files
    rm "$file_name""$year"01-"$(($year+9))"12.nc

    done

    # Repeat for last 5 year period
    ncwa -a lon "$file_name"209501-210012.nc "$file_name"209501-210012_zonal_mean.nc
    ncwa -w gw -a lat,lon -d lat,-30.,30. -d lon,0.,360. "$file_name"209501-210012.nc "$file_name"209501-210012_tropical_mean.nc
    ncwa -w gw -a lat,lon -d lat,-25.,5. -d lon,220.,280. "$file_name"209501-210012.nc "$file_name"209501-210012_EP_mean.nc

    # Delete original file
    rm "$file_name"209501-210012.nc


    # Concatenate files together 
    cdo cat "$file_name"*_zonal_mean.nc "$file_name"201501-210012_zonal_mean.nc
    cdo cat "$file_name"*_tropical_mean.nc "$file_name"201501-210012_tropical_mean.nc
    cdo cat "$file_name"*_EP_mean.nc "$file_name"201501-210012_EP_mean.nc

    # Delete files
    for year in {2015..2085..10}
    do

    rm "$file_name""$year"01-"$(($year+9))"12_zonal_mean.nc
    rm "$file_name""$year"01-"$(($year+9))"12_tropical_mean.nc
    rm "$file_name""$year"01-"$(($year+9))"12_EP_mean.nc

    done

    rm "$file_name"209501-210012_zonal_mean.nc
    rm "$file_name"209501-210012_tropical_mean.nc
    rm "$file_name"209501-210012_EP_mean.nc


    # Now calculate the zonal, tropical and East Pacific annual means
    ncra -O --mro -d time,,,12,12 "$file_name"201501-210012_zonal_mean.nc "$file_name"2015-2100_zonal_mean.nc
    ncra -O --mro -d time,,,12,12 "$file_name"201501-210012_tropical_mean.nc "$file_name"2015-2100_tropical_mean.nc
    ncra -O --mro -d time,,,12,12 "$file_name"201501-210012_EP_mean.nc "$file_name"2015-2100_EP_mean.nc

    # Now calculate the zonal, tropical and East Pacific seasonal means
    # Zonal
    ncra -O --mro -d time,"2016-01-01",,12,3 "$file_name"201501-210012_zonal_mean.nc "$file_name"2015-2100_DJF_zonal_mean.nc
    ncra -O --mro -d time,"2015-04-01",,12,3 "$file_name"201501-210012_zonal_mean.nc "$file_name"2015-2100_MAM_zonal_mean.nc
    ncra -O --mro -d time,"2015-07-01",,12,3 "$file_name"201501-210012_zonal_mean.nc "$file_name"2015-2100_JJA_zonal_mean.nc
    ncra -O --mro -d time,"2015-10-01",,12,3 "$file_name"201501-210012_zonal_mean.nc "$file_name"2015-2100_SON_zonal_mean.nc

    # Tropical
    ncra -O --mro -d time,"2016-01-01",,12,3 "$file_name"201501-210012_tropical_mean.nc "$file_name"2015-2100_DJF_tropical_mean.nc
    ncra -O --mro -d time,"2015-04-01",,12,3 "$file_name"201501-210012_tropical_mean.nc "$file_name"2015-2100_MAM_tropical_mean.nc
    ncra -O --mro -d time,"2015-07-01",,12,3 "$file_name"201501-210012_tropical_mean.nc "$file_name"2015-2100_JJA_tropical_mean.nc
    ncra -O --mro -d time,"2015-10-01",,12,3 "$file_name"201501-210012_tropical_mean.nc "$file_name"2015-2100_SON_tropical_mean.nc

    # East Pacific
    ncra -O --mro -d time,"2016-01-01",,12,3 "$file_name"201501-210012_EP_mean.nc "$file_name"2015-2100_DJF_EP_mean.nc
    ncra -O --mro -d time,"2015-04-01",,12,3 "$file_name"201501-210012_EP_mean.nc "$file_name"2015-2100_MAM_EP_mean.nc
    ncra -O --mro -d time,"2015-07-01",,12,3 "$file_name"201501-210012_EP_mean.nc "$file_name"2015-2100_JJA_EP_mean.nc
    ncra -O --mro -d time,"2015-10-01",,12,3 "$file_name"201501-210012_EP_mean.nc "$file_name"2015-2100_SON_EP_mean.nc

    # Remove files to be left with only annual and seasonal mean files
    rm "$file_name"201501-210012_zonal_mean.nc
    rm "$file_name"201501-210012_tropical_mean.nc
    rm "$file_name"201501-210012_EP_mean.nc

      
}

# Run this function for all 100 ensembles

# First 10 ensembles
branch="drift"
model="cmip6"
for ensemble in {1..10}
do
    calc_RH_vals $ensemble
done

# Ensembles 11-50
branch="amoc"
model="cmip6"
for branch_year in 123 125 128 130
do
    for ensemble in {1..10}
    do
        calc_RH_vals $ensemble $branch_year
    done
done

# Ensembles 51-60
branch="drift"
model="smbb"
for ensemble in {1..10}
do
    calc_RH_vals $ensemble
done

# Last 40 ensembles 
branch="amoc"
model="smbb"
for branch_year in 123 125 128 130
do
    for ensemble in {11..20}
    do
        calc_RH_vals $ensemble $branch_year
    done
done


