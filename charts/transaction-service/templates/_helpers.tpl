{{- define "transaction-service.name" -}}transaction-service{{- end }}
{{- define "transaction-service.fullname" -}}{{- .Release.Name | trunc 63 | trimSuffix "-" }}{{- end }}
{{- define "transaction-service.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: transaction-service
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: finance-app
app.kubernetes.io/component: microservice
{{- end }}
{{- define "transaction-service.selectorLabels" -}}
app.kubernetes.io/name: transaction-service
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
