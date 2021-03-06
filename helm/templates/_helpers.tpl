{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pm2-on-premise.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pm2-on-premise.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.mongodb.fullname" -}}
{{- printf "%s-%s" .Release.Name "mongodb" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pm2-on-premise.redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pm2-on-premise.elasticsearch.fullname" -}}
{{- printf "%s-%s" .Release.Name "elasticsearch" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pm2-on-premise.fullenv" -}}
            - name: NODE_ENV
              value: {{ .Values.nodeEnv }}
{{ if .Values.debug }}
            - name: DEBUG
              value: '*'
{{ end }}
            - name: MONGO_HOST
{{ if .Values.mongodb.mongodbHost }}
              value: {{ .Values.mongodb.mongodbHost }}
{{ else }}
              value: {{ template "pm2-on-premise.mongodb.fullname" . }}
{{ end }}
            - name: MONGODB_USERNAME
              value: {{ .Values.mongodb.mongodbUsername }}
            - name: MONGODB_PASSWORD
{{ if .Values.mongodb.mongodbPassword }}
              value: {{ .Values.mongodb.mongodbPassword }}
{{ else }}
              valueFrom:
                secretKeyRef:
                  name: {{ template "pm2-on-premise.mongodb.fullname" . }}
                  key: mongodb-password
{{ end }}
            - name: MONGODB_DATABASE
              value: {{ .Values.mongodb.mongodbDatabase }}
            - name: KM_MONGO_URL
              value: 'mongodb://$(MONGODB_USERNAME):$(MONGODB_PASSWORD)@$(MONGO_HOST):27017/$(MONGODB_DATABASE)'
            - name: REDIS_HOST
{{ if .Values.redis.redisHost }}
              value: {{ .Values.redis.redisHost }}
{{ else }}
              value: {{ template "pm2-on-premise.redis.fullname" . }}-master
{{ end }}
            - name: REDIS_PASSWORD
{{ if .Values.redis.redisPassword }}
              value: {{ .Values.redis.redisPassword }}
{{ else }}
              valueFrom:
                secretKeyRef:
                  name: {{ template "pm2-on-premise.redis.fullname" . }}
                  key: redis-password
{{ end }}
            - name: KM_REDIS_URL
              value: redis://:$(REDIS_PASSWORD)@$(REDIS_HOST):6379
            - name: ES_HOST
{{ if .Values.elasticsearch.elasticsearchHost }}
              value: {{ .Values.elasticsearch.elasticsearchHost }}
{{ else }}
              value: {{ template "pm2-on-premise.elasticsearch.fullname" . }}-client
{{ end }}
            - name: KM_ELASTICSEARCH_HOST
              value: http://$(ES_HOST):9200
            - name: KM_ELASTIC_VERSION
              value: '5.5'
{{- end -}}

{{- define "pm2-on-premise.alertworker.fullname" -}}
{{- if .Values.alertworker.fullnameOverride -}}
{{- .Values.alertworker.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.alertworker.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.alertworker.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.alertworker.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.api.fullname" -}}
{{- if .Values.api.fullnameOverride -}}
{{- .Values.api.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.api.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.api.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.api.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.digesters.fullname" -}}
{{- if .Values.digesters.fullnameOverride -}}
{{- .Values.digesters.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.digesters.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.digesters.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.digesters.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.front.fullname" -}}
{{- if .Values.front.fullnameOverride -}}
{{- .Values.front.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.front.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.front.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.front.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.notifications.fullname" -}}
{{- if .Values.notifications.fullnameOverride -}}
{{- .Values.notifications.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.notifications.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.notifications.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.notifications.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.oauth.fullname" -}}
{{- if .Values.oauth.fullnameOverride -}}
{{- .Values.oauth.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.oauth.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.oauth.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.oauth.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.prerealtime.fullname" -}}
{{- if .Values.prerealtime.fullnameOverride -}}
{{- .Values.prerealtime.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.prerealtime.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.prerealtime.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.prerealtime.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.prometheuscollector.fullname" -}}
{{- if .Values.prometheuscollector.fullnameOverride -}}
{{- .Values.prometheuscollector.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.prometheuscollector.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.prometheuscollector.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.prometheuscollector.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.prometheusexporter.fullname" -}}
{{- if .Values.prometheusexporter.fullnameOverride -}}
{{- .Values.prometheusexporter.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.prometheusexporter.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.prometheusexporter.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.prometheusexporter.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.proxy.fullname" -}}
{{- if .Values.proxy.fullnameOverride -}}
{{- .Values.proxy.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.proxy.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.proxy.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.proxy.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.realtime.fullname" -}}
{{- if .Values.realtime.fullnameOverride -}}
{{- .Values.realtime.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.realtime.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.realtime.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.realtime.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.wizard.fullname" -}}
{{- if .Values.wizard.fullnameOverride -}}
{{- .Values.wizard.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.wizard.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.wizard.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.wizard.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.webcheckworker.fullname" -}}
{{- if .Values.webcheckworker.fullnameOverride -}}
{{- .Values.webcheckworker.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.webcheckworker.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.webcheckworker.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.webcheckworker.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pm2-on-premise.zipkincollector.fullname" -}}
{{- if .Values.zipkincollector.fullnameOverride -}}
{{- .Values.zipkincollector.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.zipkincollector.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.zipkincollector.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.zipkincollector.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pm2-on-premise.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
