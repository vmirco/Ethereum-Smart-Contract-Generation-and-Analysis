import argparse

def count_non_compilable_contracts(file_path):
    non_compilable_count = 0
    
    with open(file_path, 'r') as file:
        for line in file:
            if "contract not compilable" in line:
                non_compilable_count += 1
    
    return non_compilable_count

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file_path")
    
    args = parser.parse_args()
    
    non_compilable_count = count_non_compilable_contracts(args.file_path)
    
    print(f"Numero di contratti non compilabili: {non_compilable_count}")
