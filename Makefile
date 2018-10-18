def:
	faas remove -f stack.yml --gateway 127.0.0.1:31112
	faas build -f stack.yml
	faas deploy -f stack.yml --gateway 127.0.0.1:31112

down:
	faas remove -f stack.yml --gateway 127.0.0.1:31112