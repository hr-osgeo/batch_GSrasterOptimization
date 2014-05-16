REM Name:        ini2nsh
REM Purpose:
REM
REM Author:      Darko Boto darko.boto@gmail.com
REM Description: Parse qgis customization .ini file and generate nsis .nsh file for windows registry setup
REM Created:     10.02.2014
REM Copyright:   (c) darko.boto 2014
REM Licence:     <your licence>
REM-------------------------------------------------------------------------------

@echo off

echo.
echo    -----------------------------------------------------
echo      POKRETANJE %0 BATCH SCRIPTE 
echo	 SKRIPTA MIJENJA NO_DATA VRIJEDNOSTI (256) U ALFA KANAL
echo        I OPTIMIZIRA RASTERE ZA OBJAVU PUTEM GEOSERVERA
echo ULAZNI FILE: 16 BIT TIFF RaSTER FILE SA 256 NO_DATA VRIJEDNOŠĆU
echo    -----------------------------------------------------
echo.

mkdir alpha
echo KREIRANJE PRIVREMENOG DIREKTORIJA "alpha"
mkdir result
echo KREIRANJE DIREKTORIJA "result"

echo.

REM DODAVANJE ALPHA KANALA 

echo -- KORAK 1. GDALWARP UTILITY:
echo.

for %%f in (*.tif) do (
   echo - "IZMJENA NO_DATA VRIJEDNOSTI (256) U ALPHA KANAL ZA: %%f FILE"
   gdalwarp -dstalpha -srcnodata "256 256 256" -of "GTiff" -of "GTiff" %%f alpha/%%f 
   echo.
)

echo PROMJENA DIREKTORIJA "cd alpha"
cd alpha
echo.


REM GDAL KONVERZIJA 16bit U 8bit RASTER

echo -- KORAK 2. GDAL_TRANSLATE UTILITY:
echo.


for %%f in (*.tif) do (
   echo - "KREIRANJE TILE-anog I KOMPRIMIRANOG 8 BIT RASTERA SA 4 BAND-a (alpha) ZA: %%f FILE"
   gdal_translate -ot Byte -scale -b 1 -b 2 -b 3 -b 4 -co "TILED=YES" -co COMPRESS=LZW -of "GTiff" %%f ../result/%%f
   echo.
)

echo PROMJENA DIREKTORIJA "cd result"
cd ../result
echo.


REM DODAVANJE PIRAMIDA

echo -- STEP 3. GDAL_ADDO UTILITY:
echo.

for %%f in (*.tif) do (
   echo - "KREIRANJE PIRAMIDA SA 5 OVERVIEW STUPNJEVA ZA: %%f FILE"
   gdaladdo -r average_mp --config COMPRESS_OVERVIEW PIXEL %%f 2 4 8 16 32
   echo.
)

dir
dir > result_list.txt

cd ..
echo BRISANJE DIREKTORIJA alpha
rmdir /s /q alpha

echo.
echo    -----------------------------------------------------
echo                   KRAJ IZVRSAVANJA SKRIPTE
echo    REZULTAT OBRADE RASTERA SE NALAZI U "result" DIREKTORIJU
echo    -----------------------------------------------------
echo.
)
