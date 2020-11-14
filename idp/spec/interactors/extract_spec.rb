# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

EMAIL = 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOjQxMTAwODUyNywiaXNzIjoiaWRwIiwiZXhwIjoyNjA1MzY2NDM3LCJyZWZyZXNoX3Rva2VuIjpmYWxzZSwiZW1haWwiOiJ0ZXN0QGJtc3R1LnJ1In0.gWnr9w46NAHtlw1UuKKHwtJ5j7ujeoPPvjv7_gSaRdbmxZg1vhGRa4vpi2nknByhj48bnJHWo0M49C_EwehivOjSYOw1bYu3Jg3gq04f9vSEs5PAjJcSXbReSMlnML0vuDIVWFYuathNj_xRGR4K0WliHfSgTXODe4JHjFNoVJlNGG0pxuBXRf_lawoDciDcY03-Z4cBPyi3uNukMpT3xAV-Y45LMfi--_GG-kpP2wZuYP1-dn2ozQNrTnIOaqYzTethV3wJjRDgQKYxWoxzB3T86Zi_wHaIFex-zGOVu0jRs_PcExCcnAr57LwglDQH1Y_XpY_fHgEHUN9yE_KknQ'
NO_EMAIL = 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOjQxMTAwODUyNywiaXNzIjoiaWRwIiwiZXhwIjoyNjA1MzY2NDM3LCJyZWZyZXNoX3Rva2VuIjpmYWxzZX0.lN4fhm13g7E9cmAbJ18SgRLw_uz6_rymelG-nqRZ0xdvf6wX8iEiNFQ4F-dRbRLXEwRVqRz3wFO9dj3Yh-c3-32dclrljXW8XylT_PAKcAc_U-FtYI5H1JcbU_N-9OwRjLfyiriqi4vvKjn4mW_8QKoEn9-ZlxjUjS_CIWklBHbbZga682jnCb-7_hF6O-KBw3Feb2ItxFsVbR2rnij-qpNosAinOrneOTc4r2aLsg6RYUvqBPClnHC2O3jSiZjZsFuWdR2_edmhVHieZL6krnwmkRlLOSmwQBjZgKyT6oI_4nD4vi4_KQ5AREZBky4PnDOV9iNVxYxdNgwT0Pfydw'

RSpec.describe ExtractEmail do
  it 'extracts email from decoded token' do
    expect(ExtractEmail.call(decode(EMAIL)).success?).to eq true
  end

  it 'fails when there is no email' do
    expect(ExtractEmail.call(decode(NO_EMAIL)).failure).to eq :no_email
  end

  def decode(token)
    ValidateToken.call(token).success
  end
end
