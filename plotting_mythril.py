import re
import matplotlib.pyplot as plt
import sys
from collections import defaultdict

def analyze_vulnerabilities(file_path):
    vulnerability_pattern = re.compile(r"Mythril found (\d+) Low vulnerabilities, (\d+) Medium vulnerabilities, (\d+) High vulnerabilities")

    not_compilable = 0
    total_low_vulnerabilities = 0
    total_medium_vulnerabilities = 0
    total_high_vulnerabilities = 0
    total_vulnerable_contracts = 0

    with open(file_path, 'r') as file:
        lines = file.readlines()

    for line in lines:
        if 'Mythril - contract not compilable or error during analysis' in line:
            not_compilable += 1
        else:
            match = vulnerability_pattern.search(line)
            if match:
                low_count = int(match.group(1))
                medium_count = int(match.group(2))
                high_count = int(match.group(3))

                total_low_vulnerabilities += low_count
                total_medium_vulnerabilities += medium_count
                total_high_vulnerabilities += high_count
                if(low_count + medium_count + high_count > 0): 
                    total_vulnerable_contracts += 1

    average_low = total_low_vulnerabilities / total_vulnerable_contracts if total_vulnerable_contracts > 0 else 0
    average_medium = total_medium_vulnerabilities / total_vulnerable_contracts if total_vulnerable_contracts > 0 else 0
    average_high = total_high_vulnerabilities / total_vulnerable_contracts if total_vulnerable_contracts > 0 else 0

    return total_vulnerable_contracts, not_compilable, total_low_vulnerabilities, total_medium_vulnerabilities, total_high_vulnerabilities, average_low, average_medium, average_high

def extract_vulnerabilities(data):
    vulnerabilities = defaultdict(int)
    pattern = re.compile(r"'(\d+)':\s*(\d+)")
    
    for line in data.splitlines():
        matches = pattern.findall(line)
        for match in matches:
            vulnerability_id, occurrence = match
            vulnerabilities[vulnerability_id] += int(occurrence)
    
    return dict(vulnerabilities)

#analyze_vulnerabilties return order:
#1 Total number of vulnerable contracts
#2 Total number of non compilable contracts
#3 Total number of low vulnerabilities
#4 Total number of medium vulnerabilties
#5 Totalnumber of high vulnerabilities
#6 Average number of low vulnerabilities
#7 Average number of medium vulnerabilities
#8 Average number of high vulnerabilities
def plot_data_comparison(gpt_data, deepseek_data, gpt_dict, deepseek_dict):
    #BAR CHART 1 - Comparison by Severity
    #Plot a bar chart that shows how many vulnerabilties were found divided by severity
    #Direct comparison between the models, for severity there's one bar for GPT and one for DeepSeek
    labels = ['Low', 'Medium', 'High']
    gpt_values = [gpt_data[5], gpt_data[6], gpt_data[7]]
    deepseek_values = [deepseek_data[5], deepseek_data[6], deepseek_data[7]]

    x = range(len(labels))

    plt.figure(figsize=(10, 5))
    plt.bar(x, gpt_values, width=0.4, label='GPT', color='#A30000', align='center')
    plt.bar([i + 0.4 for i in x], deepseek_values, width=0.4, label='DeepSeek', color='#336699', align='center')

    plt.xticks([i + 0.2 for i in x], labels)
    plt.ylabel('Average Number of Vulnerabilities')
    plt.legend()
    plt.show()

    #PIE CHART - with GPT data
    #Pie chart showing how many Low, Medium and High vuln were found
    plt.figure(figsize=(8, 8))
    labels_pie = ['Low', 'Medium', 'High']
    values_pie = [gpt_data[2], gpt_data[3], gpt_data[4]]
    colors_pie = ['#2E8B57', '#A30000', '#336699']
    plt.pie(values_pie, labels=labels_pie, autopct='%1.1f%%', startangle=140, colors=colors_pie)
    plt.show()

    #PIE CHART - with DeepSeek data (same as above)
    plt.figure(figsize=(8, 8))
    values_pie_deepseek = [deepseek_data[2], deepseek_data[3], deepseek_data[4]]
    plt.pie(values_pie_deepseek, labels=labels_pie, autopct='%1.1f%%', startangle=140, colors=colors_pie)
    plt.show()

    #BAR CHART 2 - Comparison with vulnerability IDs
    ids = sorted(set(gpt_dict.keys()).union(deepseek_dict.keys()))
    gpt_counts = [gpt_dict.get(id, 0) for id in ids]
    deepseek_counts = [deepseek_dict.get(id, 0) for id in ids]

    x = range(len(ids))

    plt.figure(figsize=(12, 6))
    plt.bar(x, gpt_counts, width=0.4, label='GPT', color='#A30000', align='center')
    plt.bar([i + 0.4 for i in x], deepseek_counts, width=0.4, label='DeepSeek', color='#336699', align='center')

    plt.xticks([i + 0.2 for i in x], ids, rotation=90)
    plt.ylabel('Number of Occurrences')
    plt.legend()
    plt.show()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 plotting_mythril.py <gpt_analysis_text> <deepseek_analysis_text>")
        sys.exit(1)
    
    gpt_file_path = sys.argv[1]
    deepseek_file_path = sys.argv[2]

    #GPT-4 DATA
    gpt_data = analyze_vulnerabilities(gpt_file_path)
    gpt_dict = extract_vulnerabilities(open(gpt_file_path, 'r').read())

    #DEEPSEEK-CODER DATA
    deepseek_data = analyze_vulnerabilities(deepseek_file_path)
    deepseek_dict = extract_vulnerabilities(open(deepseek_file_path, 'r').read())

    #PLOTTING
    plot_data_comparison(gpt_data, deepseek_data, gpt_dict, deepseek_dict)
