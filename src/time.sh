parallel './time_mainO{1}.x {1} {2} {3} >> data-{1}-{3}.txt' ::: 1 3 ::: $(cat probabilidades.txt) ::: {100..1000..100}
