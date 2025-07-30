import os
import sys
import csv
import multiprocessing
from multiprocessing import cpu_count
from faker import Faker

def write_records(procId, nR, output, fake):
    with open(f'{output}_{procId}', mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file, delimiter=';')
        start = (procId * nR) - (nR -1)
        for i in range(start, start + nR):
            writer.writerow([i, fake.first_name(), fake.last_name()])

if __name__ == '__main__':
    lock = multiprocessing.Lock()

    nRecord = int(sys.argv[1])
    nProc = cpu_count()
    print(f'num processi: {nProc}')
    nR = nRecord // nProc

    for i, out in enumerate(["dataset_a_fake.csv", "dataset_b_fake.csv"]):
        processes = []
        for pId in range(nProc):
            fake = Faker('it_IT')
            Faker.seed(pId + (nProc*i))
            print(f'processo {pId}: start')
            p = multiprocessing.Process(target=write_records, args=(pId+1, nR, out, fake))
            p.start()
            processes.append(p)
            
        for p in processes:
            p.join()

        with open(sys.argv[2] + out, 'w', newline='', encoding='utf-8') as outfile:
            writer = None
            for pId in range(nProc):
                with open(f'{out}_{pId+1}', 'r', encoding='utf-8') as infile:
                    reader = csv.reader(infile, delimiter=';')
                    for row in reader:
                        if writer is None:
                            writer = csv.writer(outfile, delimiter=';')
                        writer.writerow(row)
                        
        for pId in range(nProc):
            os.remove(f'{out}_{pId+1}')
                        
        
    
    



