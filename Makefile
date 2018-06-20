.PHONY: x, run, force, status, cancel, unfinished, clean, clobber, clean-stats

x:
	@echo "There is no default make target. Use 'make run' to run the SLURM pipeline."

run:
	slurm-pipeline.py --specification specification.json > status.json

force:
	slurm-pipeline.py --specification specification.json --force > status.json

status:
	@slurm-pipeline-status.py --specification status.json

cancel:
	@jobs=$$(slurm-pipeline-status.py --specification status.json --printUnfinished); if [ -z "$$jobs" ]; then echo "No unfinished jobs."; else echo "Canceling $$(echo $$jobs | tr '\012' ' ')"; scancel $$jobs; fi

unfinished:
	@slurm-pipeline-status.py --specification status.json --printUnfinished

clean:
	rm -f \
               */slurm-*.out \
               slurm-pipeline.done \
               slurm-pipeline.error \
               slurm-pipeline.running

clobber: clean
	rm -fr \
               logs \
               01-stats/*.count \
               02-map/*.sam \
               02-map/*.bam \
               03-diamond/*.json.bz2 \
               04-panel/out \
               04-panel/summary-proteins \
               04-panel/summary-virus \
               05-sample-count/*.count \
               status.json
