from sys import argv

path = argv[1].replace("\\", "/")
fn = path.split(r'/')[-1]
if fn == "":
    fn = path
print(f"{fn}")