all: 


download_data: 
	Rscript download_raw_data.R

clean_data:
	Rscript clean_raw_data.R

