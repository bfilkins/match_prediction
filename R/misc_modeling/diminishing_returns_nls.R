

set.seed(137)
#create diminishing return data
x_sim <- seq(0, 50, 1)
y_sim <- ((runif(1,10,20)*x_sim)/(runif(1,0,10)+x_sim)) + rnorm(51,0,3)

# Michaelis–Menten model
MM_mod <- nls(formula = y ~ a*x/(b + x), data = data_sim, start=c(a=10,b=.2))
# Asymptotic Regression
AR_mod <- nls(formula = y ~ a*( 1 - exp(-b*x)), data = data_sim, start = c('a'=10, 'b'=.1))


predict(MM_mod)
summary(MM_mod)

#plot
plot(x_sim,y_sim)
lines(x_sim, predict(MM_mod),lty=2,col="red",lwd=3)
lines(x_sim, predict(AR_mod),lty=2,col="red",lwd=3)


