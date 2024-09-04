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
                    total_vulnerabilities += vulnerabilities # Update the total number of vulnerabilities

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
    
    #Calculate the average number of vulnerabilities per contract
    average_vulnerabilities = total_vulnerabilities / vulnerable_contracts if vulnerable_contracts > 0 else 0 

    return non_compilable, vulnerable_contracts, average_vulnerabilities, contract_cur, total_high_severity_vulnerabilities, total_low_severity_vulnerabilities, total_medium_severity_vulnerabilities, total_optimization, total_informational, total_vulnerabilities

def plot_data(non_compilable, contracts_with_vulnerabilities, average_vulnerabilities, total_contracts, total_high_severity_vulnerabilities, total_low_severity_vulnerabilities, total_medium_severity_vulnerabilities, total_optimization, total_informational, total_vulnerabilities):
    labels = ['Non-compilable', 'With Vulnerabilities', 'Without Vulnerabilities']
    counts = [non_compilable, contracts_with_vulnerabilities, total_contracts - contracts_with_vulnerabilities]
    
    #PIE CHART 1 - Distribution of contracts, compilable/vulnerable/non-vulnerable
    plt.figure(figsize=(8, 8))
    plt.pie(counts, labels=labels, autopct='%1.1f%%', startangle=140, colors=['#2E8B57', '#A30000', '#336699'])
    plt.show()
    
    #PIE CHART 2 - Distribution of vulnerabilities by severity
    plt.figure(figsize=(10, 10))
    plt.pie([total_low_severity_vulnerabilities,
            total_medium_severity_vulnerabilities,
            total_high_severity_vulnerabilities,
            total_optimization,
            total_informational],
            labels=['Low Severity', 'Medium Severity', 'High Severity', 'Optimization Issues', 'Informational Issues'],
            autopct='%1.1f%%',
            startangle=140,
            colors=['#F4A3A3', '#9AB8E8', '#D94545', '#2D5D9B', '#B0B0B0'])
    plt.show()

    print(f"Average number of vulnerabilities per contract: {average_vulnerabilities:.2f}")
    #SAVED THE VALUE FOR EACH MODEL
    gpt_average = 7.60
    deepseek_average = 7.75
    #Bar chart that shows the average number of vulnerabilities per contract
    labels = ['DeepSeek-Coder', 'GPT-4']
    values = [deepseek_average, gpt_average]

    plt.figure(figsize=(10, 5))
    bars = plt.bar(labels, values, color=['#A30000', '#336699'], width=0.5)  
    #ADD THE VALUE ON TOP OF EACH BAR
    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.2f}', ha='center', va='bottom')
    plt.title('Average Vulnerabilities per Contract')
    plt.ylabel('Average Number of Vulnerabilities')
    plt.ylim(0, 12)
    plt.show()

def plot_comparison(gpt_results, deepseek_results):
    #BAR CHART - Average vulnerabilities per category comparing GPT and DeepSeek
    categories = ['Low Severity', 'Medium Severity', 'High Severity', 'Optimization', 'Informational']
    
    gpt_values = [gpt_results[5], gpt_results[6], gpt_results[7], gpt_results[8], gpt_results[9]]
    deepseek_values = [deepseek_results[5], deepseek_results[6], deepseek_results[7], deepseek_results[8], deepseek_results[9]]
    
    labels = categories
    width = 0.35
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    bar1 = ax.bar([i - width/2 for i in range(len(categories))], gpt_values, width, label='GPT', color='#A30000')
    bar2 = ax.bar([i + width/2 for i in range(len(categories))], deepseek_values, width, label='DeepSeek', color='#336699')
    
    #Put number over the bar
    for bar in bar1:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height, f'{height:.2f}', ha='center', va='bottom')
    
    for bar in bar2:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height, f'{height:.2f}', ha='center', va='bottom')
    
    ax.set_xticks(range(len(categories)))
    ax.set_xticklabels(labels)
    ax.legend()
    
    plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('gpt_file_path', type=str, help="Path to the GPT results file")
    parser.add_argument('deepseek_file_path', type=str, help="Path to the DeepSeek results file")
    args = parser.parse_args()
    
    #GPT DATA
    gpt_results = analyze_results(args.gpt_file_path)
    plot_data(*gpt_results)
    
    #DEEPSEEK DATA
    deepseek_results = analyze_results(args.deepseek_file_path)
    plot_data(*deepseek_results)

    #TOTAL VULNERABILITIES
    print(f"Total vulnerabilities for GPT: {gpt_results[9]}")
    print(f"Total vulnerabilities for DeepSeek: {deepseek_results[9]}")
    
    #PLOTTING
    plot_comparison(gpt_results, deepseek_results)
