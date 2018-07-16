file_path = r"C:\Users\dsx\Downloads\ceden_data_retrieval_201871612272.csv"

i = 0
with open('outfile.tab', 'w') as output:
	with open(file_path, 'r') as filedata:
		for line in filedata:
			#print(line)
			i+=1
			output.write(line)
			if (i > 10000):
				break