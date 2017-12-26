import xlrd
import sys


def format_value(value_type,value):
	if value_type == 1:
		value = value.replace("\r", " ")
		value = value.replace("\n", " ")
		value = value.replace("\\", "/")
		return value
	elif value_type == 2:
		if value == int(value):
			return int(value)
		elif type(value) == float:
			return value
		else:
			return None
	elif value_type == 4:
		if value == 1:
			return "true"
		else:
			return "false"
			



def add_quoted(src_str):
	dst_str = "\""
	for c in src_str:
		if c in ('"', '\\', '\n'):
			dst_str += '\\' + c
		elif c == '\r':
			dst_str += '\\r'
		elif c == '\0':
			dst_str += '\\000'
		else:
			dst_str += c
	
	dst_str += "\""
	return dst_str

def format_output(v):
	if type(v) == type("t") or type(v) == type(u"t"):
		if v == "nil":
			return v
		else:
			try:
				return add_quoted(v).encode("utf8")
			except Exception:
				try:
					#print "---",  type(v), len(v)
					return add_quoted(v).encode("ascii")
				except Exception:
					print "----format value error",  type(v), len(v)
					return "unknown_type"
	else:
		return str(v)

def export(sheet):
	row_count = sheet.nrows
	for r in xrange(sheet.nrows):
		count = 0
		for c in xrange(sheet.ncols):
			value_type = sheet.cell_type(r,c)
			value = sheet.cell_value(r,c)
			v = format_value(value_type,value)
			if v == None:
				count += 1

		if count == sheet.ncols:
			row_count = r
			break

	col_count = sheet.ncols
	for c in xrange(sheet.ncols):
		count = 0
		for r in xrange(sheet.nrows):
			value_type = sheet.cell_type(r,c)
			value = sheet.cell_value(r,c)
			v = format_value(value_type,value)
			if v == None:
				count += 1
		if count == sheet.nrows:
			col_count = c

	dic = {}
	for c in xrange(col_count):
		col_list = None
		if dic.has_key(c):
			col_list = dic[c]
		else:
			col_list = []

		for r in xrange(row_count):
			value_type = sheet.cell_type(r,c)
			value = sheet.cell_value(r,c)
			v = format_value(value_type,value)

			if v is not None and value != "":
				col_list.append(v)
			else:
				col_list.append('nil')

		dic[c] = col_list

	return dic


def main():
	if sys.argv[1] == None:
		print "error import file name"
		return

	book = xlrd.open_workbook(sys.argv[1])

	export_dic = {}

	for sheet in book.sheets():
		if sheet.nrows > 0 and sheet.ncols > 0:
			dic = export(sheet)
			export_dic[sheet.name] = dic

	sys.stdout.write("{ \n")
	for name,sheet in export_dic.items():
		sys.stdout.write("\t[%s] = {\n" % format_output(name))

		for c,content in sheet.items():
			sys.stdout.write("\t\t{\n" )
			for item in content:
				sys.stdout.write("\t\t\t%s,\n"% format_output(item))
			sys.stdout.write("\t\t},\n")

		sys.stdout.write("\t},\n")

	sys.stdout.write("}")





if __name__ == "__main__":
	main()