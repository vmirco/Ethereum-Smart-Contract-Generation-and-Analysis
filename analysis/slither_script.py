import os
import sys
import subprocess
import re

#Function to run Slither analysis on a Solidity contract file
def run_slither_analysis(contract_file):
    try:
        result = subprocess.run(
            ['slither', contract_file, '--print', 'human-summary'],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        
        return result.stderr.strip()
    
    except subprocess.CalledProcessError as e:
        return e.stderr

#Function to extract the number of vulnerabilities found from the output
def extract_vulnerabilities_count(output):
    total_vulnerabilities = 0
    informational = 0
    optimization = 0
    low_issues = 0
    medium_issues = 0
    high_issues = 0

    lines = output.split('\n')

    for line in lines:
        if line.startswith("Compilation warnings/errors on"):
                return -1, -1, -1, -1, -1, -1
        if "Number of optimization issues:" in line:
            optimization = int(line.split(':')[1].strip())
        elif "Number of informational issues:" in line:
            informational = int(line.split(':')[1].strip())
        elif "Number of low issues:" in line:
            low_issues = int(line.split(':')[1].strip())
        elif "Number of medium issues:" in line:
            medium_issues = int(line.split(':')[1].strip())
        elif "Number of high issues:" in line:
            high_issues = int(line.split(':')[1].strip())

    total_vulnerabilities = optimization + informational + low_issues + medium_issues + high_issues

    return total_vulnerabilities, high_issues, low_issues, medium_issues, optimization, informational

def main():
    #NEED THE CONTRACTS DIRECTORY
    if len(sys.argv) < 2:
        print("Usage: python3 slither_script.py <contracts_directory>")
        sys.exit(1)

    contracts_directory = sys.argv[1]
    if not os.path.isdir(contracts_directory):
        print(f"Folder {contracts_directory} not found")
        sys.exit(1)

    #ITERATE OVER THE FILES IN THE DIRECTORY
    for filename in os.listdir(contracts_directory):
        if filename.endswith(".sol"):
            contract_file = os.path.join(contracts_directory, filename)

            output = run_slither_analysis(contract_file)
            vulnerabilities_total, high_issues, low_issues, medium_issues, optimization, informational = extract_vulnerabilities_count(output)

            #RESULTS
            if vulnerabilities_total == -1:
                print(f"{filename}: Slither - contract not compilable")
            else:
                print(f"{filename}: Slither found {vulnerabilities_total} vulnerability(s), {high_issues} of type high, {low_issues} of type low, {medium_issues} of type medium, {optimization} of type optimization, {informational} of type informational")

if __name__ == "__main__":
    main()
