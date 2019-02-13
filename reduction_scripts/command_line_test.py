# # reads in input when scripting
# if __name__ == "__main__":
# 	import sys
# 	try:
# 		out = sys.argv[3]
# 	except IndexError:
# 		out = ''
# 	try:
# 		yeshi = sys.argv[4]
# 		yeshi = yeshi == 'True' or yeshi == 'true'
# 	except IndexError:
# 		yeshi = True
# 	convert(str(sys.argv[1]),str(sys.argv[2]),str(out),bool(yeshi))
#
import sys
print("This is the name of the script: ", sys.argv[0])
print("Number of arguments: ", len(sys.argv))
print("The arguments are: " , str(sys.argv))
