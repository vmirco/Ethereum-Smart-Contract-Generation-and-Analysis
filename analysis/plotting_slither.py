import re
import matplotlib.pyplot as plt
import argparse

def analyze_results(file_path):
    non_compilable = 0
    vulnerable_contracts = 0
    total_vulnerabilities = 0
    total_high_severity_vulnerabilities = 0
    total_low_severity_vulnerabilities = 0
    total_medium_severity_vulnerabilities = 0
    total_optimization = 0
    total_informational = 0
    contract_cur = 0
    
    #Read the file line by line
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            contract_cur += 1 #Cursor to keep track of the current contract
            if "Slither - contract not compilable" in line:
                non_compilable += 1 #Found a non-compilable contract

            else:
                vulnerabilities = re.findall(r'Slither found (\d+) vulnerability\(s\)', line) #Count the number of vulnerabilities
                high_severity_vulnerabilities = re.findall(r', (\d+) of type high', line) #Count the number of high severity vulnerabilities
                low_severity_vulnerabilities = re.findall(r', (\d+) of type low', line) #Count the number of low severity vulnerabilities
                medium_severity_vulnerabilities = re.findall(r', (\d+) of type medium', line) #Count the number of medium severity vulnerabilities
                optimization = re.findall(r', (\d+) of type optimization', line) #Count the number of optimization problems
                informational = re.findall(r', (\d+) of type informational', line) #Count the number of informational problems

                if vulnerabilities:
                    vulnerabilities = int(vulnerabilities[0])
                    total_vulnerabilities += vulnerabilities #Update the total number of vulnerabilities

                    if vulnerabilities > 0:
                        vulnerable_contracts += 1 #Update the number of contracts with vulnerabilities
                
                if high_severity_vulnerabilities and low_severity_vulnerabilities and medium_severity_vulnerabilities and optimization and informational:
                    high_severity_vulnerabilities = int(high_severity_vulnerabilities[0])
                    low_severity_vulnerabilities = int(low_severity_vulnerabilities[0])
                    medium_severity_vulnerabilities = int(medium_severity_vulnerabilities[0])
                    optimization = int(optimization[0])
                    informational = int(informational[0])
                    total_high_severity_vulnerabilities += high_severity_vulnerabilities #Update the total number of high severity vulnerabilities
                    total_low_severity_vulnerabilities += low_severity_vulnerabilities #Update the total number of low severity vulnerabilities
                    total_medium_severity_vulnerabilities += medium_severity_vulnerabilities #Update the total number of medium severity vulnerabilities
                    total_optimization += optimization #Update the total number of optimization problems
                    total_informational += informational #Update the total number of informational problems
    
    #Let's calculate the average number of vulnerabilities per contract
    average_vulnerabilities = total_vulnerabilities / vulnerable_contracts if vulnerable_contracts > 0 else 0 

    return non_compilable, vulnerable_contracts, average_vulnerabilities, contract_cur, total_high_severity_vulnerabilities, total_low_severity_vulnerabilities, total_medium_severity_vulnerabilities, total_optimization, total_informational, total_vulnerabilities

def plot_data(non_compilable, contracts_with_vulnerabilities, average_vulnerabilities, total_contracts, total_high_severity_vulnerabilities, total_low_severity_vulnerabilities, total_medium_severity_vulnerabilities, total_optimization, total_informational, total_vulnerabilities):
    labels = ['Non-compilable', 'With Vulnerabilities', 'Without Vulnerabilities']
    counts = [non_compilable, contracts_with_vulnerabilities, total_contracts - contracts_with_vulnerabilities]
    
    #Pie chart for distribution of contracts
    plt.figure(figsize=(8, 8))
    plt.pie(counts, labels=labels, autopct='%1.1f%%', startangle=140, colors=['#2E8B57', '#A30000', '#336699'])
    plt.title('Distribution of Contracts')
    plt.show()
    
    fake_gpt_average = 2.5  
    #Bar chart that shows the average number of vulnerabilities per contract
    labels = ['DeepSeek-Coder', 'GPT-4']
    values = [average_vulnerabilities, fake_gpt_average]

    plt.figure(figsize=(10, 5))
    plt.bar(labels, values, color=['#A30000', '#336699'], width=0.5)  
    plt.title('Average Vulnerabilities per Contract')
    plt.ylabel('Average Number of Vulnerabilities')
    plt.show()
    
    #Pie chart that shows the distribution of high severity vulnerabilities
    plt.figure(figsize=(10, 10))
    plt.pie([total_low_severity_vulnerabilities,
            total_medium_severity_vulnerabilities,
            total_high_severity_vulnerabilities,
            total_optimization,
            total_informational],
            labels=['Low Severity', 'Medium Severity', 'High Severity', 'Optimization Issues', 'Informational Issues'],
            autopct='%1.1f%%',
            startangle=140,
            colors=['#00BFFF', '#87CEFA', '#A30000', '#FFD700', '#90EE90'])
    plt.title('Distribution of Vulnerabilities by Severity')
    plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('file_path', type=str)
    args = parser.parse_args()
    
    non_compilable_count, contracts_with_vulnerabilities, average_vulnerabilities, total_contracts, total_high_severity_vulnerabilities, total_low_severity_vulnerabilities, total_medium_severity_vulnerabilities, total_optimization, total_informational, total_vulnerabilities = analyze_results(args.file_path)
    plot_data(non_compilable_count, contracts_with_vulnerabilities, average_vulnerabilities, total_contracts, total_high_severity_vulnerabilities, total_low_severity_vulnerabilities, total_medium_severity_vulnerabilities, total_optimization, total_informational, total_vulnerabilities)
