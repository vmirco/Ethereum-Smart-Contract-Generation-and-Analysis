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

    #Dictionaries to store the number of vulnerabilities per contract
    low_per_contract = defaultdict(int)
    medium_per_contract = defaultdict(int)
    high_per_contract = defaultdict(int)

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

                #Update the counters of vulnerabilities
                total_low_vulnerabilities += low_count
                total_medium_vulnerabilities += medium_count
                total_high_vulnerabilities += high_count
                if(low_count + medium_count + high_count > 0): total_vulnerable_contracts += 1

                contract_name = line.split(':')[0].strip()
                #Update the counters of vulnerabilities per contract
                #At the end of the loop, the dictionaries will contain the number of vulnerabilities for each contract
                low_per_contract[contract_name] = low_count
                medium_per_contract[contract_name] = medium_count
                high_per_contract[contract_name] = high_count

    #Average number of vulnerabilities per contract
    average_low = total_low_vulnerabilities / total_vulnerable_contracts if total_vulnerable_contracts > 0 else 0
    average_medium = total_medium_vulnerabilities / total_vulnerable_contracts if total_vulnerable_contracts > 0 else 0
    average_high = total_high_vulnerabilities / total_vulnerable_contracts if total_vulnerable_contracts > 0 else 0

    #PRINT RESULTS
    print(f"Non compilable contracts: {not_compilable}")
    print(f"Low vulnerabilities: {total_low_vulnerabilities}")
    print(f"Medium vulnerabilities: {total_medium_vulnerabilities}")
    print(f"High vulnerabilities: {total_high_vulnerabilities}")
    
    print("\nVulnerabilities type average per contract:")
    print(f"Low: {average_low:.2f}")
    print(f"Medium: {average_medium:.2f}")
    print(f"High: {average_high:.2f}")
    
    return total_vulnerable_contracts, not_compilable, total_low_vulnerabilities, total_medium_vulnerabilities, total_high_vulnerabilities, average_low, average_medium, average_high

def extract_vulnerabilities(data):
    vulnerabilities = defaultdict(int)
    
    #Regex pattern to match the ID and the occurrences of each vulnerability
    pattern = re.compile(r"'(\d+)':\s*(\d+)")
    
    for line in data.splitlines():
        matches = pattern.findall(line)
        for match in matches:
            vulnerability_id, occurrence = match
            vulnerabilities[vulnerability_id] += int(occurrence)
    
    return dict(vulnerabilities)

def plot_data(total_vulnerable_contracts, not_compilable, total_low_vulnerabilities, total_medium_vulnerabilities, total_high_vulnerabilities, average_low, average_medium, average_high, vulnerability_dict):
    
    #BAR CHART - Average Vulnerabilities per Contract by Severity
    labels = ['Low', 'Medium', 'High']
    values = [average_low, average_medium, average_high]

    plt.figure(figsize=(10, 5))
    plt.bar(labels, values, color=['#2E8B57', '#A30000', '#336699'], width=0.5)
    plt.title('Average Vulnerabilities per Contract by Severity')
    plt.ylabel('Average Number of Vulnerabilities')
    plt.ylim(0, 3) 
    plt.show()

    #PIE CHART - Total Vulnerability Distribution
    plt.figure(figsize=(8, 8))
    labels_pie = ['Low', 'Medium', 'High']
    values_pie = [total_low_vulnerabilities, total_medium_vulnerabilities, total_high_vulnerabilities]
    colors_pie = ['#2E8B57', '#A30000', '#336699']

    wedges, texts, autotexts = plt.pie(values_pie, labels=labels_pie, autopct='%1.1f%%', startangle=140, colors=colors_pie)
    plt.title('Total Vulnerability Distribution')

    #Notation for the total number of vulnerable contracts
    plt.gca().add_artist(plt.Circle((1.1, 1.1), 0.1, color='white', transform=plt.gca().transAxes, zorder=0))
    plt.text(1.1, 1.1, f'Total Vulnerable Contracts: {total_vulnerable_contracts}', horizontalalignment='left', verticalalignment='top', transform=plt.gca().transAxes, fontsize=12, bbox=dict(facecolor='white', edgecolor='black', boxstyle='round,pad=0.5'))

    plt.show()

    # BAR CHART - Total Vulnerability Distribution by ID
    plt.figure(figsize=(10, 5))
    #Extract the labels and values from the dictionary and calculate the total number of vulnerabilities
    labels_vul = list(vulnerability_dict.keys())
    values_vul = list(vulnerability_dict.values())
    total_vulnerabilities = sum(values_vul)

    colors = ['#A30000' if i % 2 == 0 else '#336699' for i in range(len(labels_vul))] #Alternate colors for the bars
    bars = plt.bar(labels_vul, values_vul, color=colors)
    plt.title('Vulnerability Distribution by ID')
    plt.xlabel('Vulnerability ID')
    plt.ylabel('Number of Occurrences')
    #Add a notation for the total number of vulnerabilities at the top of the chart
    plt.text(1.05, 1.05, f'Total Vulnerabilities: {total_vulnerabilities}',
             horizontalalignment='right', verticalalignment='top',
             transform=plt.gca().transAxes,
             fontsize=12, bbox=dict(facecolor='white', edgecolor='black', boxstyle='round,pad=0.5'))
    #Add the number of occurrences at the top of each bar
    for bar in bars:
        yval = bar.get_height()
        plt.text(bar.get_x() + bar.get_width() / 2.0, yval + 0.1, int(yval),
                 ha='center', va='bottom', fontsize=10, color='black')

    plt.show()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 plotting_mythril.py <analysis_text>")
        sys.exit(1)
    
    file_path = sys.argv[1]
    total_vulnerable_contracts, not_compilable, total_low_vulnerabilities, total_medium_vulnerabilities, total_high_vulnerabilities, average_low, average_medium, average_high = analyze_vulnerabilities(file_path)
    vulnerability_dict = extract_vulnerabilities(open(file_path, 'r').read())
    plot_data(total_vulnerable_contracts, not_compilable, total_low_vulnerabilities, total_medium_vulnerabilities, total_high_vulnerabilities, average_low, average_medium, average_high, vulnerability_dict)