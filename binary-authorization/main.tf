terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0, < 7.0.0"
    }
  }
  required_version = "~> 1.9.0"
}

provider "google" {
  project = var.project_id
}

# keyring stores public key
resource "google_kms_key_ring" "keyring" {
  name     = "attestor-key-ring"
  location = "global"
}

data "google_kms_crypto_key_version" "version" {
  crypto_key = google_kms_crypto_key.crypto-key.id
}

# public key used to sign images
resource "google_kms_crypto_key" "crypto-key" {
  name     = "attestor-key"
  key_ring = google_kms_key_ring.keyring.id
  purpose  = "ASYMMETRIC_SIGN"

  version_template {
    algorithm = "RSA_SIGN_PKCS1_4096_SHA512"
  }

}

resource "google_container_analysis_note" "note" {
  name = "attestor-note"
  attestation_authority {
    hint {
      human_readable_name = "Attestor Note"
    }
  }
}

resource "google_binary_authorization_attestor" "attestor" {
  name = "attestor"
  attestation_authority_note {
    note_reference = google_container_analysis_note.note.name
    public_keys {
      id = data.google_kms_crypto_key_version.version.id
      pkix_public_key {
        public_key_pem      = data.google_kms_crypto_key_version.version.public_key[0].pem
        signature_algorithm = data.google_kms_crypto_key_version.version.public_key[0].algorithm
      }
    }
  }
}

# policy, which verifies created attestations
resource "google_binary_authorization_policy" "policy" {
  admission_whitelist_patterns {
    # don't required attestation for istio components
    name_pattern = "docker.io/istio/*"
  }

  default_admission_rule {
    evaluation_mode         = "REQUIRE_ATTESTATION"
    enforcement_mode        = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    require_attestations_by = [google_binary_authorization_attestor.attestor.name]
  }

  global_policy_evaluation_mode = "ENABLE"
}