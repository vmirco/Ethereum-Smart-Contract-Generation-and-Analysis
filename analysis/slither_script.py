import os
import sys
import subprocess

#Function to run Slither analysis on a Solidity contract file
def run_slither_analysis(contract_file, exclude_low):
    base_command = ["slither", contract_file, "--exclude-dependencies", "--exclude-optimization", "--exclude-informational"]

    #If requested add the --exclude-low flag
    if exclude_low:
        base_command.append("--exclude-low")
    
    try:
        result = subprocess.run(base_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        return result.stdout.strip()
    
    except subprocess.CalledProcessError as e:
        return e.stderr

#Function to extract the number of vulnerabilities found from the output
def extract_vulnerabilities_count(output):
    try:
        lines = output.split('\n')
        for line in lines:
            if line.startswith("Compilation warnings/errors on"):
                return -1

        #Search for the string "result(s) found" in the output
        results_start = output.rfind("result(s) found")
        if results_start != -1:
            #Get the number of vulnerabilities found, which is the number before "result(s) found"
            number_start = output.rfind(',', 0, results_start) + 1
            #Extract and convert the number to an integer
            count = int(output[number_start:results_start].strip())
            return count
    except ValueError:
        pass
    return 0

def main():
    #ASK FOR DIRECTORY AS INPUT
    if len(sys.argv) < 2:
        print("Usage: python3 slither_script.py <contracts_directory>")
        sys.exit(1)

    #CHECK IF THE DIRECTORY EXISTS
    contracts_directory = sys.argv[1]
    if not os.path.isdir(contracts_directory):
        print(f"Folder {contracts_directory} not found")
        sys.exit(1)

    #ITERATE OVER THE FILES IN THE DIRECTORY
    for filename in os.listdir(contracts_directory):
        if filename.endswith(".sol"):
            contract_file = os.path.join(contracts_directory, filename)

            #ANALYSIS WITHOUT --EXCLUDE-LOW FLAG
            output_without_exclude_low = run_slither_analysis(contract_file, exclude_low=False)
            vulnerabilities_count = extract_vulnerabilities_count(output_without_exclude_low)

            #ANALYSIS WITH --EXCLUDE-LOW FLAG
            output_with_exclude_low = run_slither_analysis(contract_file, exclude_low=True)
            high_severity_count = extract_vulnerabilities_count(output_with_exclude_low)

            #PRINT THE RESULTS
            if vulnerabilities_count == -1 or high_severity_count == -1:
                print(f"{filename}: Slither - contract not compilable")
            else:
                print(f"{filename}: Slither found {vulnerabilities_count} vulnerability(s), {high_severity_count} of type high.")

if __name__ == "__main__":
    main()
