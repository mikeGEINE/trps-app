# frozen_string_literal: true

RSpec.shared_context 'tokens' do
  let(:valid) { 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJib29raW5nIiwiZXhwIjoyNjA3MDc5NzQ2LCJjYWxsYmFja191cmwiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvand0L2FjcyJ9.Xz8UUADu0JWUtOWMYD1Erbu0GUYB2FYwRQYTSuJ_d5qxWt6hmdroOgwHkNTH6nfi738OEP6WMUmDIkFTkMYESRCw8i9qLCJSd7M84lRxmJ4IY_1R9AJr3yPzpriu_0hv1KfmHZX_t7xfPoFyibq0XvvjKaf1oj0M06yFwr43qZxfMhEvS8DyrHUZwozdzha32Cy1FuVXD0v5p9-xTSDNj3exi7ORsykydZEnXmOXjs6ZVLwIQVKp4wA3WRkwC5C5jyL1t3OCSve56M02GWmJyAR4ctaEGyP-Hc7_sant6AtI--FfFsnTSmIgBA3zseVnVDDzCFgJ7jseY-360vYGBA' }
  let(:invalid) { 'eyJbGciOiJSUzI1NiJ9.eyJpc3MiOiJib29raW5nIiwiZXhwIjoyNjA3MDc5NzQ2LCJjYWxsYmFja191cmwiOiJodHRwOi8vbG9jxob3N0OjgwODAvand0L2FjcyJ9.Xz8UUADu0JWUtOWMYD1Erbu0GUYB2FYwRQYTSuJ_d5qxWt6hmdroOgwHkNTH6nfi738OEP6WMUmDIkFTkMYESRCw8i9qLCJSd7M84lRxmJ4IY_1R9AJr3yPzpriu_0hv1KfmHZX_t7xfPoFyibq0XvvjKaf1oj0M06yFwr43qZxfMhEvS8DyrHUZwozdzhCy1FuVXD0v5p9-xTSDNj3exi7ORsykydZEnXmOXjs6ZVLwIQVKp4wA3WRkwC5C5jyL1t3OCSve56M02GWmJyA4ctaEGyP-Hc7_sant6AtI--FfFsnTSmIgBA3zseVnDDzCFgJ7jseY-360vYBA' }
  let(:expired) { 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJib29raW5nIiwiZXhwIjo2MDUzNTc0MjgsImNhbGxiYWNrX3VybCI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODA4MC9qd3QvYWNzIn0.Ypm_U9mhxO0vGfE-g8Bq9JP8Qn3Q5wMflY3lAtc9-kZvYKqwqvWQZ1MCtgAbEKejaV5toeS_Ur5geUmXsuHN3Qk_u09YxGlCCA7amgL8iFNW8GswXh-beFfF1JcVUVocQtBNhVeHfiLK4jONsVNClhmfPTC1pEMGoQIiZW7kyYKrqCquUJDHhMip_cpoL2L2nF2Is-vTdrhRv2j6p5Qxjix3eCy7ncoK0IYtasLk3u5wGzYWkDUOchjNNjZf6r2Vt25wXRwHanDLbfDASDMcyesn7HD2dU6dzcGCWVCx7iGV5tuLmjBrbF6lqFBAGeE70Wj16XHnJ0Bp9pDJgSn6MA' }
  let(:no_iss) { 'eyJhbGciOiJSUzI1NiJ9.eyJleHAiOjI2MDcwNzk3NDYsImNhbGxiYWNrX3VybCI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODA4MC9qd3QvYWNzIn0.QlGuP6qi2XhVo6lXcCiioxsTwAcOc3RCnO1c_G1HoKqkN9-YB5JylWKTJrDO2WW4cxEopFHXaxo_ObtU1wN95xQn1IHImH7F1Ju-FgsL0GiHBqr4rKd7kxZr0l-7EXmtiEV4K4e___okSnBL31c_6ZbMxEf_8Sej3LV3dVLZiS9jig1nc3k_-1a4ZMgzFvYsh_8Xaqc8h8D-Jthgc8aSTbrlqlwJKANc2yc22xETtqoGgExFi0w-W_ayLdN69N5vFa2AiEl0hsJ8_hmI-EnWx-7gvFcFcr6TFw42gL5v4wAarPs86rpP-9FxF336Dbhvf4fKVrO9IAqmmQskEBOqYQ' }
  let(:wrong_iss) { 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJpbmciLCJleHAiOjI2MDcwNzk3NDYsImNhbGxiYWNrX3VybCI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODA4MC9qd3QvYWNzIn0.S1a7dGcriO31eBWgqrzk-U2Y982k2cbWpE_gzlPX_j1ankXN5Ao6Jv7CW7URlkx09Y6SQJ5QAf1qlrNP1C18qpk0bDWmJV0jA01nEp26UNzBD6gaAf0Ft-gi4dQlZYEDoNTQMsYBo7lLq8USnRo2BdAAHo7wq5kpqdi96b5tmbmkdafl1N2RcgjZuFr0TILiIAwTPtx2en1VhShpRZlTr6vWr6Rhm7vBDEWwgHk95BCyx_wC-oDinP3dhrU4MRrtQdSMFa0EdTiVsOj5gYNsFovqOnBv-1DAUoshPSLQtyW0sp8sBSFopasSrOwK1ESHpv1GQJkIJ5LMD6y17kO7ww' }
  let(:login) { 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJib29raW5nIiwiZXhwIjoyNjA3MDc5NzQ2LCJjYWxsYmFja191cmwiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvand0L2FjcyJ9.Xz8UUADu0JWUtOWMYD1Erbu0GUYB2FYwRQYTSuJ_d5qxWt6hmdroOgwHkNTH6nfi738OEP6WMUmDIkFTkMYESRCw8i9qLCJSd7M84lRxmJ4IY_1R9AJr3yPzpriu_0hv1KfmHZX_t7xfPoFyibq0XvvjKaf1oj0M06yFwr43qZxfMhEvS8DyrHUZwozdzha32Cy1FuVXD0v5p9-xTSDNj3exi7ORsykydZEnXmOXjs6ZVLwIQVKp4wA3WRkwC5C5jyL1t3OCSve56M02GWmJyAR4ctaEGyP-Hc7_sant6AtI--FfFsnTSmIgBA3zseVnVDDzCFgJ7jseY-360vYGBA' }
  let(:logout) { 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJib29raW5nIiwiZXhwIjoyNjA3MDgwMDYxLCJjYWxsYmFja191cmwiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvand0L2xvZ291dCJ9.HetjYXph0YaOiUNhyZpIMYwis_Pi_Dpa_fKMem-VAJD1Lc8Bv6Gzwj1062t3GxJpEI4gZPRR_c_11pAq_ETaFz4nUKjHPrlskD8-vONa1qnD-OxERTbMFUjwxVqBMZH6BLkF3KQVK5LjpPDFkkHhRbsvtok1TeabywRHdrRUm3HGGTkoVsSjj90k3rcLU7T99z6DS1EGhnVkht0hsqvymnf0FS9627jzM8WcHWvKPU4kMJ9utcJDpjd87Rg4H0LuSEPykRnU0cDR2VsxotBiTnaLESvDoakFCpojaVL1XiN0CSEbSSVMcb7Fb5hmZ6hw4d-AO154-Qwojx5EquDCng' }
  let(:correct_user) do
    { email: 'test@bmstu.ru', password: 'password', remember_me: '0' }
  end
  let(:incorrect_login) do
    { email: 'temst@bmstu.ru', password: 'password', remember_me: '0' }
  end
  let(:incorrect_password) do
    { email: 'test@bmstu.ru', password: 'pamsword', remember_me: '0' }
  end
  let(:email) { 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJpZHAiLCJleHAiOjI2MDcwODAwNjEsInN1YiI6NDExMDA4NTI3LCJlbWFpbCI6InRlc3RAYm1zdHUucnUifQ.coIq_Efv1yfdczfdmS5_Wqd8gP52INNwd5mwu-U-33vimnVrFUbsInFjSVFbr3tCF3kv-NjEc3irpxASNx99C-XrKujlCoP24NxuqMimPYB_vvYnfMAJuILEis1aJWhQoST-aLcda9HNgTSwmcVI8g9-qMljb_p3TH0-OLYJHAcAX_N-FDigDQ2hNVmdXdfjXneMBhl1Tu7Y95MuNMkWYTj_qbB75DNN4n4-Ck97zgEtGoUtR-FhWNStmWUktA933nBJaNNSX0SlNFrTIOKMQrw6Q7PH6husFEkn-QhXfebsH3-RE8TcemClN2o5eqpnvubS4xYPLEhte2KwchK0ZQ' }
  let(:no_email) { 'eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJpZHAiLCJleHAiOjI2MDcwODAwNjEsInN1YiI6NDExMDA4NTI3fQ.L63zwJm9XUDrhP-ReOIV-RWUIKbQvIx_PZ_2LUMjx6Fa5OSu_5ZceWqs274AAruCQE2Spa4dQOjgZBJW0qMZOdpR940_G1ZmMK6u1HPHMKUH7Gg6WYORzN0IDbGDse76uwBgfyrfUT-lJFvdP6EYCBlg1VYXbLzgzInogMFnPFmHoMusmtQ0A6AJwP5TBC9zGey6UXzUsTNtqLGanfhWm_3f9KqhJpfTS0sEjcG9PhQZi4sJHUV_EUU0BsEV2dQp_MicbJieEIAaAoH3Qn0V-nbZAvVslB4pZUKp5orbduz0MDoPuwK397OJX3ct70_rCQjcQNI8UHie3FQDCRvuyw' }
end
