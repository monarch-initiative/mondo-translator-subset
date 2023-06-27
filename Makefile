
ROBOT=robot
MONDO_PURL=http://purl.obolibrary.org/obo/mondo.owl
MONDO_TRANSLATOR_PURL=http://purl.translator.org/mondo.owl
TMPDIR=tmp

$(TMPDIR)/mondo.owl:
	mkdir -p $(TMPDIR)
	wget $(MONDO_PURL) -O $@

exclusion-list-sparql.txt: $(TMPDIR)/mondo.owl
	$(ROBOT) query -i $< -f csv --query translator-excluded.sparql $@

exclusion-list.txt: exclusion-list-sparql.txt exclusion-list-manual.txt
	cat $^ | sort | uniq > $@
.PRECIOUS: exclusion-list.txt

mondo-translator.owl: $(TMPDIR)/mondo.owl exclusion-list.txt
	$(ROBOT) remove -i $< -T exclusion-list.txt --output $@ &&\
	$(ROBOT) annotate --input $@ --ontology-iri $(MONDO_TRANSLATOR_PURL) -o $@.tmp.owl && mv $@.tmp.owl $@
.PRECIOUS: mondo-translator.owl
