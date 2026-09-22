from diagrams import Cluster, Diagram, Edge
from diagrams.aws.network import ALB, InternetGateway, Route53,NATGateway
from diagrams.onprem.client import Client
from diagrams.onprem.queue import Celery
from diagrams.programming.framework import FastAPI, React, Spring, Django
from diagrams.aws.database import RDSMysqlInstance
from diagrams.aws.compute import EC2, Lambda
from diagrams.onprem.workflow import Airflow
from diagrams.aws.integration import SNS, SF
from diagrams.aws.storage import S3
from diagrams.aws.ml import Personalize
from diagrams.aws.mobile import APIGateway
from diagrams.generic.network import VPN

graph_attr = {
    "fontsize": "45",
    "bgcolor": "lightgray",
    "5c":   [{"area":  "5"}, {"fillcolor": "silver"}],
    "10c":  [{"area": "10"}, {"fillcolor": "silver"}],
    "20c":  [{"area": "20"}, {"fillcolor": "silver"}],
    "50c":  [{"area": "50"}, {"fillcolor": "silver"}],
    "$1":   [{"area":"100"}, {"fillcolor": "gold"}],
    "$2":   [{"area":"200"}, {"fillcolor": "gold"}]
}

with Diagram("ECS", show=True, direction="TB") as diag:
    vpn = VPN("VPN")
    client = Client("Client")
    developer = Client("Developer")
    with Cluster("AWS\nacme-corp"):
        dns = Route53("DNS")
        ig = InternetGateway("InternetGateway")
        with Cluster("Data Flow", graph_attr=graph_attr) as df:
            sns = SNS("SNS")
            s3_snapthot = S3("S3\nSnapshot")
            s3_personalize = S3("S3\nPersonalize")
            lambda_1 = Lambda("Lambda")
            lambda_2 = Lambda("Lambda")
            personalize = Personalize("Personalize")
            api_gateway = APIGateway("APIGateway")
            sf = SF("StepFunctions")

        with Cluster("acme\n(10.0.0.0/16)") as vpc:
            with Cluster("Availability Zone-[ A, C ]") as az:
                with Cluster("퍼블릭 서브넷\nacme-public-ap-northeast-[ 2a, 2c ]\n[ (10.0.0.0/20), (10.0.48.0/20) ]") \
                        as public_subnet:
                    bastion = EC2("Bastion")
                    frontend_alb = ALB("frontend-alb")
                    backend_alb = ALB("backend-alb")
                    am_admin_alb = ALB("elb-am-front-admin-prod-ecs")
                    airflow_alb = ALB("acme-airflow")
                    nat = NATGateway("NAT Gateway")

                with Cluster("프라이빗 서브넷\nacme-private-ap-northeast-[ 2a, 2c ]\n[ (10.0.16.0/20), (10.0.64.0/20) ]") \
                        as private_subnet:
                    with Cluster("ECS Cluster\nacme-cloud\n[파트너, 예약 클러스터]"):
                        spc = Spring("spring-gateway-prod-1_2\n[Spring Cloud]")
                        partner_backend_names = "beacon partner-back acme-user partner-management-back".split()
                        partner_backends = [Spring(name) for name in partner_backend_names]
                        partner_front = React("partner_front")
                        beacon_scan = FastAPI("beacon-scan-prod-1_2")

                        spc >> partner_backends

                    with Cluster("ECS Cluster\nacmemall-prod\n[아크메몰]"):
                        commerce_back = Django("am-backend-prod-1_2\n[몰 백엔드]")
                        commerce_front = React("am-frontend-prod-1_2\n[몰 프론트엔드]")
                        commerce_celery = Celery("celery")
                        commerce_admin = React("service-am-front-admin-prod\n[몰 어드민]")
                        commerce_back - commerce_celery

                    with Cluster("ECS Cluster\nacme-airflow\n[에어플로우]",):
                        airflow = Airflow("acme-airflow")

                    rds = RDSMysqlInstance("RDS")

    client >> ig >> [
        frontend_alb,
        backend_alb,
        developer >> vpn >> bastion,
        am_admin_alb,
        airflow_alb,
        nat
    ]

    frontend_alb >> Edge(label="/mall, /") >> commerce_front
    frontend_alb >> Edge(label="/h") >> partner_front

    backend_alb >> [
        commerce_back,
        spc,
        beacon_scan
    ]

    am_admin_alb >> commerce_admin
    airflow_alb >> airflow

    rds >> sns >> lambda_1 >> s3_snapthot >> s3_personalize >>  personalize >> sf >> lambda_2 >> api_gateway
    personalize << sf << lambda_2 << api_gateway

