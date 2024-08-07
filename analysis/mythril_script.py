import os
import sys
import subprocess

#Function to run Mythril analysis on a Solidity contract file
def run_mythril_analysis(contract_file):
    try:
        result = subprocess.run(
            ['myth', 'analyze', contract_file, '--execution-timeout', '300'],
            capture_output=True, #Capture the output and error
            text=True #Convert the output and error to strings 
        )
        
        return result.stdout
    
    except FileNotFoundError:
        print("MYHTRIL NOT FOUND")
    except Exception as e:
        print(f"Error while performing Mythril analysis: {e}")

def count_vulnerabilities(output):
    #Check if the output is empty
    if not output.strip():  
        return -1 #Return -1 to indicate a fatal error

    #Count the number of vulnerabilities found for each severity
    severity_counts = {'Low': 0, 'Medium': 0, 'High': 0}

    #Check each line of the output
    lines = output.split('\n')
    for line in lines:
        if 'Severity:' in line:
            #Extract the severity from the line
            severity = line.split('Severity: ')[1].strip()
            if severity in severity_counts:
                severity_counts[severity] += 1

    return severity_counts

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 mythril_script.py [-f <contracts_directory>] <contract_file.sol>")
        sys.exit(1)

    #IF THERE'S A -F FLAG IT MEANS WE'RE ANALYZING A DIRECTORY
    if sys.argv[1] == "-f":
        if len(sys.argv) < 3:
            print("Usage: python3 mythril_script.py -f <contracts_directory>")
            sys.exit(1)
        contracts_directory = sys.argv[2]
        if not os.path.isdir(contracts_directory):
            print(f"Folder {contracts_directory} not found")
            sys.exit(1)
        
        #ITERATE OVER THE FILES IN THE DIRECTORY
        for filename in os.listdir(contracts_directory):
            if filename.endswith(".sol"):
                contract_file = os.path.join(contracts_directory, filename)
                output = run_mythril_analysis(contract_file)
                results = count_vulnerabilities(output)

                if results == -1:
                    print(f"{filename}: Mythril - contract not compilable or error during analysis")
                else:
                    print(f"{filename}: Mythril found {results['Low']} Low vulnerabilities, {results['Medium']} Medium vulnerabilities, {results['High']} High vulnerabilities")
    else:
        #IF THERE'S NO -F FLAG, WE'RE ANALYZING A SINGLE FILE
        contract_file = sys.argv[1]
        if not os.path.isfile(contract_file):
            print(f"File {contract_file} not found")
            sys.exit(1)

        output = run_mythril_analysis(contract_file)
        results = count_vulnerabilities(output)

        if results == -1:
            print(f"{contract_file}: Mythril - contract not compilable or error during analysis")
        else:
            print(f"{contract_file}: Mythril found {results['Low']} Low vulnerabilities, {results['Medium']} Medium vulnerabilities, {results['High']} High vulnerabilities")


if __name__ == "__main__":
    main()
