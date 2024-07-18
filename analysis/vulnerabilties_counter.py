import argparse

def count_vulnerabilities(file_path):
    severity_counts = {'Low': 0, 'Medium': 0, 'High': 0}

    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if 'Severity:' in line:
                severity = line.split('Severity: ')[1].strip()
                if severity in severity_counts:
                    severity_counts[severity] += 1

    return severity_counts

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('file_path', type=str)
    args = parser.parse_args()

    counts = count_vulnerabilities(args.file_path)
    for severity, count in counts.items():
        print(f'{severity}: {count}')

if __name__ == '__main__':
    main()
