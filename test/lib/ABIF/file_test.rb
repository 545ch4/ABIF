require_relative '../../test_helper'

describe ABIF::File do
	describe 'omitting file/filename' do
		it 'raises an Error' do
			Proc.new { ABIF::File.new }.must_raise ArgumentError
		end
	end
	
	describe 'invalid file/filehandle' do
		it 'invalid file raises an Exception' do
			Proc.new { ABIF::File.new('test/files/invalid.abif') }.must_raise IOError
		end

		it 'non-existing file raises an Exception' do
			Proc.new { ABIF::File.new('test/files/foo.abif') }.must_raise IOError
		end

		it 'empty filehandle raises an Exception' do
			Proc.new { ABIF::File.new(File.new) }.must_raise ArgumentError
		end
	end
	
	describe ABIF::File, 'valid filename' do
		subject { ABIF::File.new('test/files/valid.abif') }

		it 'is an instance of ABIF::File' do
			subject.must_be_instance_of ABIF::File
		end

		it 'filetype is ABIF' do
			subject.filetype.must_equal 'ABIF'
		end

		it 'fileversion is 101' do
			subject.fileversion.must_equal 101
		end

		it 'data is a Hash' do
			subject.data.must_be_kind_of Hash
		end

		{
			'AEPt_1' => '329a2798ac4a2024f904a4900de7600d',
			'AEPt_2' => '329a2798ac4a2024f904a4900de7600d',
			'APFN_2' => '509a32e5f2979be945f61cddbd14622c',
			'APXV_1' => '39c6844c921cf69656adaa2a8e4aea0c',
			'APrN_1' => '509a32e5f2979be945f61cddbd14622c',
			'APrV_1' => '3cf3aef9902754f1c9178e32f5fe1ddc',
			'APrX_1' => '773e4cd95581ad061589066058e65d4f',
			'ARTN_1' => '8d5162ca104fa7e79fe80fd92bb657fb',
			'ASPF_1' => '35dba5d75538a9bbe0b4da4422759a0e',
			'ASPt_1' => '220e850bfe79cb3526b375bc6dcdd2ef',
			'ASPt_2' => '220e850bfe79cb3526b375bc6dcdd2ef',
			'AUDT_1' => '49c8922d68864bb83c04879c1589a0fb',
			'B1Pt_1' => 'af7e8bea94ff3c20159e249200b6aa18',
			'B1Pt_2' => 'af7e8bea94ff3c20159e249200b6aa18',
			'BCTS_1' => '162bb794a66800199501e1e9de7a15df',
			'BufT_1' => '83a08dbe51340d001d2e7a3f8708e8cb',
			'CCut_1' => 'b95b0b3bc23f39b3c04bc2baf211ba5b',
			'CMNT_1' => '81bba32c7b86600386d96930ec17fda4',
			'CTID_1' => '46f79adeafce95e4fdd7b6aebad1699e',
			'CTNM_1' => '46f79adeafce95e4fdd7b6aebad1699e',
			'CTOw_1' => 'c446a4c96a0fe001210b71144c2268f9',
			'CTTL_1' => '74c70c8291e9dacf1935132d58229634',
			'CpEP_1' => '35dba5d75538a9bbe0b4da4422759a0e',
			'DATA_1' => 'c29a483afbeb83172305fb0803f3f264',
			'DATA_2' => 'd9f5d923f13c66ff2385ee9cac1ba2f3',
			'DATA_3' => 'e14a88b6353558b6af927de5ec1e070a',
			'DATA_4' => '2b60b8f09786c6c182f53da105483bba',
			'DATA_5' => '6f501928683d29942b95d5dad46e2e26',
			'DATA_6' => 'f66e5d54b3606d9e060351c85a2ef733',
			'DATA_7' => '7de240b0d5c835a9242555aaaa425d7a',
			'DATA_8' => '272c59f929d32af7a1d655d175cf7a0e',
			'DATA_9' => '66200730a3dc10020304032cc257dbd1',
			'DATA_10' => '80238386cad29c86e1afc5d9a4d6622e',
			'DATA_11' => '6d20453b6705c0144f954e9751b61c51',
			'DATA_12' => '49061ea4bee661346a8d4ece6a606a3b',
			'DCHT_1' => '8d5162ca104fa7e79fe80fd92bb657fb',
			'DSam_1' => '35dba5d75538a9bbe0b4da4422759a0e',
			'DySN_1' => 'c300e27b7c225652d4130f053f807199',
			'Dye#_1' => 'e962e23c139e7252904b9221d9967442',
			'DyeN_1' => 'b654f7796f95e5ed17096a82a0b28315',
			'DyeN_2' => '207d360b49d1b72c0c35c89833757e5c',
			'DyeN_3' => 'ac4b808acb1fc85fa0060bc92f489c69',
			'DyeN_4' => '0ac0051af6ece5afeacf8e53e1dade59',
			'DyeW_1' => 'f9639b0987d2ad3a3ae945ee29c889b4',
			'DyeW_2' => '01df866ea9d6a730be6e319110ecfda0',
			'DyeW_3' => 'c0280f103f34474ab0107746f80736fd',
			'DyeW_4' => '47f2ba5a7a71c4646d8add9de01d8368',
			'EPVt_1' => 'aea034f6800b624bf4d8d9fd4553d264',
			'EVNT_1' => '10d4ece1db63d754b5ef1ba8fb635269',
			'EVNT_2' => '9a81c64cb96fc6b7327bb2613c52e89d',
			'EVNT_3' => 'fec688b3587dff8bb2c12a59cee0763e',
			'EVNT_4' => '906341f47061764eb805b0b57b3cd7cc',
			'FTab_1' => '21beecaab27020d9069dee9a570296d8',
			'FVoc_1' => '139268d7ad20b68f72faa0b1691cac14',
			'FWO__1' => '9f40a00e83bbaf678fe218b11f81d49e',
			'Feat_1' => 'f9131fe168d95c26058ae03cff8e6be0',
			'GTyp_1' => 'c7b375c0c538659369eee293b1cd8986',
			'HCFG_1' => 'dbe992717239d8f63333a14fae4232c1',
			'HCFG_2' => '9c0224cfb93aa409728cbac69fdf614b',
			'HCFG_3' => '96cd52a8c96d12ba88c6ba36c316603d',
			'HCFG_4' => 'fed17cd2cc23396408f8c2b480d71836',
			'InSc_1' => '2a30f5f3b7d1a97cb6132480b992d984',
			'InVt_1' => '423c57007341da0749aa1d8bb0da8042',
			'LANE_1' => '6615ab6435d4f1da792f1e6fa230cb29',
			'LIMS_1' => '6b3b0fa06550a54ba95f2e78dfb213b4',
			'LNTD_1' => '8a8783242b7b77de148a06a0bab42ba9',
			'LsrP_1' => '0a4f74e275e1168915d8d512ed22bf0c',
			'MCHN_1' => 'ff90c90ed28916bb58eb2f56f425b41f',
			'MODF_1' => '013f5a3ac5836a46be81dee59261f68d',
			'MODL_1' => '59afde3cd75ce96556b9d5b3ce95fef5',
			'NAVG_1' => '35dba5d75538a9bbe0b4da4422759a0e',
			'NLNE_1' => '2375ef9e856b982a6f9e5b8fb903e6d7',
			'NOIS_1' => '60afc12c44f69325eb1906a147339931',
			'PBAS_1' => '214591fbf4e0c6032961ffb3dc685aaf',
			'PBAS_2' => '214591fbf4e0c6032961ffb3dc685aaf',
			'PCON_1' => '59cf9b876ec3410633cb72058af1cf8e',
			'PCON_2' => '59cf9b876ec3410633cb72058af1cf8e',
			'PDMF_1' => '94827116b0e6fec7abd084917c8cfc33',
			'PDMF_2' => '94827116b0e6fec7abd084917c8cfc33',
			'PLOC_1' => '87f2292a0f208ed70cb915c4d6c625e7',
			'PLOC_2' => '87f2292a0f208ed70cb915c4d6c625e7',
			'PSZE_1' => '2375ef9e856b982a6f9e5b8fb903e6d7',
			'PTYP_1' => 'f75f3b63236ce233758cc898ebe835d0',
			'PXLB_1' => 'f2577a6fc29b900fe7d4c6321346be48',
			'RGNm_1' => '779dfa8b1b7a5cfd8063493b4bf2be46',
			'RGOw_1' => 'b0b576a3a438583bd475a14acf06bf8b',
			'RMXV_1' => '2f7bb230c70819aeb10b45a709bcf48f',
			'RMdN_1' => '013f5a3ac5836a46be81dee59261f68d',
			'RMdV_1' => '2f7bb230c70819aeb10b45a709bcf48f',
			'RMdX_1' => '41b6d91073540a2a199bf9f089e11a29',
			'RPrN_1' => '21d72202012057acf64ec7d3aa52ee42',
			'RPrV_1' => '2f7bb230c70819aeb10b45a709bcf48f',
			'RUND_1' => '21e7f6441ffe6ef6c36db98592ae0810',
			'RUND_2' => '21e7f6441ffe6ef6c36db98592ae0810',
			'RUND_3' => '21e7f6441ffe6ef6c36db98592ae0810',
			'RUND_4' => '21e7f6441ffe6ef6c36db98592ae0810',
			'RUNT_1' => '42a575cff8de9a296db610df9cff6f1f',
			'RUNT_2' => '8647ea4a1090319b27562610d831172e',
			'RUNT_3' => '1523ed7e16b541e809eb6acacf5f32c1',
			'RUNT_4' => '337a52990fce3bea946d4fa60d0f51aa',
			'Rate_1' => '9f1074af1ce98833fbf4775c5f3595cb',
			'RunN_1' => '2048de7707e4fdc395175ce4784dce18',
			'S/N%_1' => 'fbd3b15939b954654a38824ec1e82eb7',
			'SCAN_1' => '329a2798ac4a2024f904a4900de7600d',
			'SMED_1' => '0edefa708c51887ad9b3fbe1ea9e7e82',
			'SMLt_1' => 'aed6e480b8aad696f3bb3a2781cd55d6',
			'SMPL_1' => '172160c679614e93d5c07ef7b7a2441f',
			'SPAC_1' => '3e58eb892f1ff04c1da6acf6509f976b',
			'SPAC_2' => 'e991d1ef3f35a5da0b8b724490a6f21a',
			'SPAC_3' => '3e58eb892f1ff04c1da6acf6509f976b',
			'SVER_1' => 'a629005e3c810e8491172eebd622a57b',
			'SVER_2' => 'cbd989d62be7257144760e24edeaf516',
			'SVER_3' => '783e7db369d5e7d7d57e5c76a1dec609',
			'Scal_1' => '8796ada1698c9940b7cf9264407731b1',
			'Scan_1' => '329a2798ac4a2024f904a4900de7600d',
			'TUBE_1' => 'aafe2f8af7d2109f20d5ae4c488bf1c6',
			'Tmpr_1' => '1be08982f722684e69bdf6c5549d67ba',
			'User_1' => 'c446a4c96a0fe001210b71144c2268f9',
			'phAR_1' => '14a685bc2583777f837ed9d24798d915',
			'phCH_1' => '89a93d4bcb2615549a98b93d2e2f5c96',
			'phDY_1' => '7153f0402307a99a60929d7b5dcd886b',
			'phQL_1' => 'e6cd5c7f942fc1c21557adbc97739b8c',
			'phTR_1' => 'b95b0b3bc23f39b3c04bc2baf211ba5b',
			'phTR_2' => '14a685bc2583777f837ed9d24798d915'
		}.each do |key, md5|
			it "MD5 of data['#{key}'] equals '#{md5}'" do
				subject.data[key].wont_be_nil
				Digest::MD5.hexdigest(subject.data[key].inspect).must_equal md5
			end
		end 
	end

	describe 'supported?' do
		it 'return false on unsupported file' do
			ABIF::File.supported?('test/files/invalid.abif').must_equal false
		end

		it 'return true on supported file' do
			ABIF::File.supported?('test/files/valid.abif').must_equal true
		end

		it 'raise an exception on non-existing file' do
			Proc.new { ABIF::File.supported?('test/files/foo.abif') }.must_raise IOError
		end
	end
end
