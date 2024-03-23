library(readxl)
library(dplyr)
library(ggplot2)
library(corrplot)
library(xlsx)
library(psych)
library("cluster")
library("fpc")

DatosEnt<-read_excel("infoclientebanca.xlsx")
getwd()

str(DatosEnt)
DatosEnt$CLIENTE<-as.factor(DatosEnt$CLIENTE)

VariableE <- select(DatosEnt,-c(CLIENTE,grupo_de_cliente,Sitio_consumo_masfrecuente))
VariableC <- select(DatosEnt,CLIENTE,grupo_de_cliente,Sitio_consumo_masfrecuente)

CV <-function(var){(sd(var)/mean(var))*100}

cvs<-apply(VariableE,2,CV)
#obtengo la descriptiva

AnalisiDescE<-describe(VariableE)
#uno el Coeficiente de variación

AnalisiDescE<-cbind(AnalisiDescE,cvs)
AnalisiDescE

hist1 <- ggplot(VariableE, aes(Numero_de_transacciones)) + geom_histogram(fill="blue", colour="white")
hist1
hist2 <- ggplot(VariableE, aes(promedio_por_transaccion)) + geom_histogram(fill="blue", colour="white")
hist2
hist3 <- ggplot(VariableE, aes(porcentaje_visa_nacional)) + geom_histogram(fill="blue", colour="white")
hist3
hist4 <- ggplot(VariableE, aes(porcentaje_visa_internacional)) + geom_histogram(fill="blue", colour="white")
hist4
hist5 <- ggplot(VariableE, aes(porcentaje_mastercard_nacional)) + geom_histogram(fill="blue", colour="white")
hist5
hist6 <- ggplot(VariableE, aes(Porcentaje_otrafranquicia_nacional)) + geom_histogram(fill="blue", colour="white")
hist6
hist7 <- ggplot(VariableE, aes(porcentaje_otrafranquicia_internacional)) + geom_histogram(fill="blue", colour="white")
hist7
hist8 <- ggplot(VariableE, aes(porcentaje_manana)) + geom_histogram(fill="blue", colour="white")
hist8
hist9 <- ggplot(VariableE, aes(porcentaje_tarde)) + geom_histogram(fill="blue", colour="white")
hist9
hist10 <- ggplot(VariableE, aes(porcentaje_noche)) + geom_histogram(fill="blue", colour="white")
hist10
rm("hist1", "hist2", "hist3","hist4", "hist5", "hist6","hist7", "hist8", "hist9","hist10")

colnames(VariableE)<-c("Numero_de_transacciones","promedio_por_transaccion","transaccion_minima","transaccion_maxima","desviacion_por_transaccion","%_visa_nacional","%_visa_internacional","%_mastercard_nacional","%_mastercard_internacional","%_otrafranquicia_nacional","%_otrafranquicia_internacional","%_nacional_total","%_internacional_total","%_manana","%_tarde","%_noche","%_DOMINGO","%_LUNES","%_MARTES","%_MIERCOLES","%_JUEVES","%_VIERNES","%_SABADO")
correlacion<-round(cor(VariableE), 1)

write.xlsx(correlacion, "C:/Users/ASUS/Documents/Corr1.xlsx")

Var<-select(VariableE,'Numero_de_transacciones','promedio_por_transaccion')

Var2<-apply(Var, 2, log1p)

VarFin1<-as.data.frame(cbind(Var2))

Transforma <-function(x,y){
  c<- runif(1, min=0, max=1)
  abs(qnorm(c,x,y))
}

VisaN<-VariableE$`%_visa_nacional`
MasterN<-VariableE$`%_mastercard_nacional`
Otras<-VariableE$`%_otrafranquicia_nacional`+VariableE$`%_visa_internacional`+VariableE$`%_otrafranquicia_internacional`+VariableE$`%_mastercard_internacional`
Var3<-select(VariableE,`%_LUNES`,`%_MARTES`,`%_MIERCOLES`,`%_JUEVES`,`%_VIERNES`,`%_SABADO`,`%_DOMINGO`)

Var4<-cbind(Var3,VisaN,MasterN,Otras ,VariableE$`%_manana`,VariableE$`%_tarde`,VariableE$`%_noche`)

Var5<-apply(1+Transforma(VariableE$promedio_por_transaccion,VariableE$desviacion_por_transaccion)*Var4*VariableE$Numero_de_transacciones, 2, log1p)

VarFin2<-as.data.frame(cbind(Var5))

VarFinFi<-cbind(VarFin1,VarFin2)

VarFinFi<-as.data.frame(scale(VarFinFi))

VarFinFin<-select(VarFinFi,-c(Numero_de_transacciones))

colnames(VarFinFin)<-c("promedio_por_transaccion","LUNES","MARTES","MIERCOLES","JUEVES","VIERNES","SABADO","DOMINGO","visaN","MasterN","Otras","Manana","Tarde","Noche")
m<-describe(VarFinFin)
VarCorr<-describe(VarFinFin)

write.csv(m, "C:/Users/ASUS/Documents/esta2.csv")

correlacion<-round(cor(VarFinFin), 1)
hist1 <- ggplot(VarFinFin, aes(promedio_por_transaccion)) + geom_histogram(fill="blue", colour="white")
hist1
hist2 <- ggplot(VarFinFin, aes(LUNES)) + geom_histogram(fill="blue", colour="white")
hist2
hist3 <- ggplot(VarFinFin, aes(visaN)) + geom_histogram(fill="blue", colour="white")
hist3

set.seed(5935)

a<-sample(1:47863,482,replace=F)

Muestra<-VarFinFin[a,]

#calculo la suma de cuadrados total
wss <- (nrow(Muestra)-1)*sum(apply(Muestra,2,var))
#calculo para cada soluciÃ³n de clustering 
for (i in 2:15) wss[i] <- sum(kmeans(Muestra,
                                     centers=i, nstart=10)$withinss)
plot(1:15, wss, type="b", xlab="Número de Clusters",
     ylab="Suma de cuadrados") 

set.seed(2) #Para evitar aleatoriedad en los resultados
clustering.asw <- kmeansruns(Muestra,krange=2:15,criterion="asw",iter.max=100, runs= 100,critout=TRUE)
clustering.asw$bestk

gscar<-clusGap(Muestra,FUN=kmeans,K.max=15,B=60)
gscar

#ejecuciÃ³n de k-means
Bancluster<-kmeans(VarFinFin,centers=9,nstart=10,iter.max=20)
#tamaÃ±o de grupos
Bancluster$size
#numero de iteraciones
Bancluster$iter
#centros de grupos
Bancluster$centers

Centros<-Bancluster$centers

write.xlsx(Centros, "C:/Users/ASUS/Documents/centros.xlsx")

VarFinFin$cluster<-Bancluster$cluster



JERARQUI<-dist(Centros,method="euclidean")
jerarqu<-hclust(JERARQUI)

grafdend<-as.dendrogram(jerarqu)
grafdend<-set(grafdend,"labels_cex",0.5)
#ver el resultado
plot(grafdend,horiz=TRUE, main="Complete")

kclusters <- clusterboot(VarFinFin,B=10,clustermethod=kmeansCBI,k=9,seed=2)
c<-kclusters$bootmean
kclusters$bootmean


Punto <-function(x){
  case_when(
    x == 3 |x == 9 ~ 2,
    x == 6 ~ 4,
    x == 5 ~ 3,
    x == 1 | x == 2 | x == 4 ~ 1,
    x == 7 | x == 8 ~ 5
  )
  
}

n<-Punto(VarFinFin$cluster)

DatosEnt$cluster<-n
DatosEnt$cluster<-as.factor(DatosEnt$cluster)
str(DatosEnt)
write.csv(DatosEnt, 'Resultados.csv')
