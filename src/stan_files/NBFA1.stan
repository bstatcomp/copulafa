data {
  int<lower=0> n;
  int<lower=0> m;
  int<lower=0> p;
  int g[n];
  int<lower=1> ng;
  int X[m,n];
}

parameters {
  matrix<lower=0>[p,ng] Theta;
  vector<lower=0>[p] rk;
  vector<lower=0, upper=1>[p] pk;
  simplex[m] simp[p];
  vector<lower=0, upper=1>[ng] prob;
}

transformed parameters {
  matrix<lower=0>[m,p] Psi;
  matrix<lower=0>[m,ng] phi;
  matrix<lower=0>[m,ng] mu;
  for (i in 1:p) {
    Psi[ ,i] = simp[i];
  }
  for (i in 1:ng)
    phi[ ,i] = Psi * Theta[ ,i];
  for (i in 1:ng) {
    for (j in 1:m) {
      mu[j,i] = (phi[j,i] * prob[i]) / (1 - prob[i]);
    }
  }
}

model {
  for (i in 1:p) {
    simp[i] ~ dirichlet(rep_vector(1.0, m));
  }
  for (i in 1:ng) {
    for (j in 1:p) {
      Theta[j,i] ~ gamma(rk[j], pk[j] / (1 - pk[j]));
    }
  }
  for (i in 1:ng) {
    prob[i] ~ beta(1,1);
  }
  for (i in 1:n)
    X[ ,i] ~ neg_binomial_2(mu[ ,g[i]], phi[ ,g[i]]);
}
