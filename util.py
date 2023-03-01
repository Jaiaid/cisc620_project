from configparser import ConfigParser


def conn_config_loader(config_filepath):
	parser = ConfigParser()
	parser.read(config_filepath)

	info = {}
	for param_tup in parser.items("connection_param"):
		info[param_tup[0]] = param_tup[1]

	return info
