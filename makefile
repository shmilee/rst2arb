test_latex_option = -f rst --template=latex-cjk.tex --latex-engine=xelatex -N --toc -V cjk=yes \
					-V mainfont=Arial -V monofont='Courier New' -V sansfont='Times New Roman' \
					-V geometry:left=2cm,right=2cm,top=2.5cm,bottom=2.5cm

rst2arb:

test:
	@echo "-- article report --"
	pandoc $(test_latex_option) -V documentclass=article README.rst -o cache/test-article.pdf
	pandoc $(test_latex_option) -V documentclass=report README.rst -o cache/test-report.pdf
	@echo "-- beamer --"
	bash ./test-beamer.sh all	

install:


pre:


clean:
	-rm cache/test*.pdf


.PHONY : clean 
