import git
import pandas as pd

repo = git.Repo("../../")
tree = repo.tree()

commit_dates = pd.DataFrame(columns=['filename', 'latest_commit_date'])

for blob in tree.traverse():
    if (blob.path.startswith('data-processed') & blob.path.endswith('.csv')):
        commit = next(repo.iter_commits(paths=blob.path))
        commit_dates.loc[len(commit_dates)] = [blob.path.split("/")[-1], str(pd.to_datetime(commit.committed_date, unit='s').date())]
        
commit_dates.to_csv('commit_dates.csv', index=False)
