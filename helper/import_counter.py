import argparse
import os

def count_import_statements(folder_path):
    import_count = 0
    
    for file_name in os.listdir(folder_path):
        if file_name.endswith(".sol"):
            file_path = os.path.join(folder_path, file_name)
            with open(file_path, 'r') as file:
                for line in file:
                    if "import" in line:
                        import_count += 1
                        break  
    
    return import_count

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("folder_path")
    
    args = parser.parse_args()
    
    import_count = count_import_statements(args.folder_path)
    
    print(f"Numero di file .sol che contengono lo statement 'import': {import_count}")
